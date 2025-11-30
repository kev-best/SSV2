// Test script to verify the sneaks-api is working
const SneaksAPI = require('sneaks-api');
const sneaks = new SneaksAPI();

console.log('🧪 Testing SneaksAPI...\n');

// Test 1: Get Most Popular
console.log('Test 1: getMostPopular(3)');
sneaks.getMostPopular(3, (err, products) => {
    if (err) {
        console.error('❌ Error:', err);
    } else {
        console.log('✅ Success! Found', products.length, 'popular sneakers');
        console.log('First sneaker:', products[0]?.shoeName);
    }
    console.log('\n---\n');
    
    // Test 2: Search Products
    console.log('Test 2: getProducts("Yeezy Cinder", 3)');
    sneaks.getProducts("Yeezy Cinder", 3, function(err, products){
        if (err) {
            console.error('❌ Error:', err);
        } else {
            console.log('✅ Success! Found', products.length, 'sneakers');
            products.forEach((p, i) => {
                console.log(`  ${i + 1}. ${p.shoeName} - ${p.styleID}`);
            });
        }
        console.log('\n---\n');
        
        // Test 3: Get Product Prices
        console.log('Test 3: getProductPrices("FY2903")');
        sneaks.getProductPrices("FY2903", (err, product) => {
            if (err) {
                console.error('❌ Error:', err);
            } else {
                console.log('✅ Success!');
                console.log('  Name:', product.shoeName);
                console.log('  Retail Price:', product.retailPrice);
                console.log('  StockX Price:', product.lowestResellPrice?.stockX);
                console.log('  Images:', product.imageLinks?.length);
            }
            console.log('\n---\n');
            console.log('✅ All tests completed!');
        });
    });
});

