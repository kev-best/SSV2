
How to Run, 

Backend:
1. Move Backend copy into different directory outside of project directory
2. Then npm install
3. Run with npm start

Frontend:
1. First run backend 
2. open project in xcode and run simulator
3. simulator should work with backend

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
