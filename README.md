TODO 
Fix sneaker errors in backend database, ensure only sneakers found appear on maintab, possibly bc of flightclub and stadium goods? 

errors:
Error loading sneaker FY2903: keyNotFound(CodingKeys(stringValue: "data", intValue: nil), Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key CodingKeys(stringValue: \"data\", intValue: nil) (\"data\").", underlyingError: nil))
Error loading sneaker FY4176: keyNotFound(CodingKeys(stringValue: "data", intValue: nil), Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key CodingKeys(stringValue: \"data\", intValue: nil) (\"data\").", underlyingError: nil))

Backend errors:
{
  '$schema': 'https://api.kicks.dev/schemas/ErrorModel.json',
  title: 'Not Found',
  status: 404,
  detail: 'Product not found'
}
{
  '$schema': 'https://api.kicks.dev/schemas/ErrorModel.json',
  title: 'Not Found',
  status: 404,
  detail: 'Product not found'
}
{
  '$schema': 'https://api.kicks.dev/schemas/ErrorModel.json',
  title: 'Not Found',
  status: 404,
  detail: 'Product not found'
}
