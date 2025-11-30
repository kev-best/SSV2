require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());

const KICKS = axios.create({
  baseURL: 'https://api.kicks.dev',
  headers: {
    // 2) auth header format
    Authorization: process.env.KICKS_API_KEY
  },
  timeout: 15000
});

/**
 * Normalize StockX → your app's Sneaker shape
 */
function mapStockXProduct(p) {
  // Safe helpers
  const images = Array.isArray(p.gallery) && p.gallery.length ? p.gallery : (p.image ? [p.image] : []);
  // Use StockX min_price as lowest floor if present
  const lowest = typeof p.min_price === 'number' ? Math.round(p.min_price) : undefined;

  return {
    styleID: p.slug || p.id,             // 3) use slug as canonical styleID
    shoeName: p.title || p.model || '',
    brand: p.brand || undefined,
    colorway: p.category || undefined,
    retailPrice: undefined,               // StockX search payload doesn’t expose retail easily
    releaseDate: undefined,               // not in list payload
    imageLinks: images,
    resellLinks: { stockX: p.link || null, goat: null, flightClub: null, stadiumGoods: null },
    lowestResellPrice: {
      stockX: lowest ?? undefined,
      goat: undefined, flightClub: undefined, stadiumGoods: undefined
    },
    resellPrices: {},                     // detail call can enrich later
    thumbnail: images[0] || null,
    description: p.description || null,
    source: 'stockx'
  };
}

/**
 * Normalize GOAT → your app's Sneaker shape
 */
function mapGoatProduct(p) {
  const images = Array.isArray(p.images) && p.images.length ? p.images : (p.image_url ? [p.image_url] : []);
  // Pick the lowest ask across variants if present
  let lowest;
  if (Array.isArray(p.variants) && p.variants.length) {
    lowest = p.variants
      .map(v => typeof v.lowest_ask === 'number' ? v.lowest_ask : Infinity)
      .reduce((a, b) => Math.min(a, b), Infinity);
    if (!isFinite(lowest)) lowest = undefined;
    else lowest = Math.round(lowest);
  }

  return {
    styleID: p.slug || String(p.id),
    shoeName: p.name || p.model || '',
    brand: p.brand || undefined,
    colorway: p.colorway || undefined,
    retailPrice: p.retail_prices && typeof p.retail_prices.USD === 'string'
      ? Number(p.retail_prices.USD) : undefined,
    releaseDate: p.release_date || undefined,
    imageLinks: images,
    resellLinks: { stockX: null, goat: p.link || null, flightClub: null, stadiumGoods: null },
    lowestResellPrice: {
      stockX: undefined,
      goat: lowest ?? undefined,
      flightClub: undefined, stadiumGoods: undefined
    },
    resellPrices: {},
    thumbnail: images[0] || null,
    description: p.description || null,
    source: 'goat'
  };
}

/**
 * GET /api/products
 * - Proxies to Kicks.dev based on ?source=stockx|goat
 * - Accepts query, brand, limit, page
 *   (We’ll use brand='Nike' and limit=5 on the iOS side for your "replace most popular" row)
 */
app.get('/api/products', async (req, res) => {
  try {
    const { source = 'stockx', query, brand, limit = 20, page = 1 } = req.query;

    if (!['stockx', 'goat'].includes(source)) {
      return res.status(400).json({ error: "source must be 'stockx' or 'goat'" });
    }

    if (source === 'stockx') {
      const params = {
        query,
        limit,
        page,
        // Using filters for brand (Kicks.dev note: filters not supported with other pre-defined filters; here we only send filters)
        filters: brand ? `brand = '${brand}'` : undefined
      };
      const { data } = await KICKS.get('/v3/stockx/products', { params });
      const items = (data?.data || []).map(mapStockXProduct);
      return res.json({ data: items });
    } else {
      const params = {
        query,
        limit,
        page,
        filters: brand ? `brand = '${brand}'` : undefined
      };
      const { data } = await KICKS.get('/v3/goat/products', { params });
      const items = (data?.data || []).map(mapGoatProduct);
      return res.json({ data: items });
    }
  } catch (err) {
    console.error(err?.response?.data || err.message);
    res.status(500).json({ error: 'Upstream error', detail: err?.response?.data || err.message });
  }
});

/**
 * 3) GET /api/product/:id?source=stockx|goat
 *    Fetch detail by slug/id from chosen source and normalize to your app shape.
 */
app.get('/api/product/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { source = 'stockx' } = req.query;

    if (!['stockx', 'goat'].includes(source)) {
      return res.status(400).json({ error: "source must be 'stockx' or 'goat'" });
    }

    if (source === 'stockx') {
      const { data } = await KICKS.get(`/v3/stockx/products/${encodeURIComponent(id)}`, {
        params: { 'display[variants]': true, 'display[prices]': true }
      });
      const p = data?.data;
      const normalized = mapStockXProduct(p);

      // Enrich resellPrices map using variants lowest price per size if present
      const pricesBySize = {};
      if (Array.isArray(p?.variants)) {
        for (const v of p.variants) {
          if (v?.size && typeof v.lowest_ask === 'number') {
            pricesBySize[v.size] = { stockX: Math.round(v.lowest_ask) };
          }
        }
      }
      normalized.resellPrices = pricesBySize;
      normalized.releaseDate = p?.created_at || normalized.releaseDate;
      normalized.description = p?.description || normalized.description;

      return res.json({ data: normalized });
    } else {
      const { data } = await KICKS.get(`/v3/goat/products/${encodeURIComponent(id)}`);
      const p = data?.data;
      const normalized = mapGoatProduct(p);

      const pricesBySize = {};
      if (Array.isArray(p?.variants)) {
        for (const v of p.variants) {
          if (v?.size && typeof v.lowest_ask === 'number') {
            pricesBySize[v.size] = { goat: Math.round(v.lowest_ask) };
          }
        }
      }
      normalized.resellPrices = pricesBySize;

      return res.json({ data: normalized });
    }
  } catch (err) {
    console.error(err?.response?.data || err.message);
    res.status(500).json({ error: 'Upstream error', detail: err?.response?.data || err.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`proxy listening on :${port}`));
