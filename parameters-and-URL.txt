let wikipediaURl = "https://en.wikipedia.org/w/api.php"

  let parameters : [String:String] = [
  "format" : "json",
  "action" : "query",
  "prop" : "extracts",
  "exintro" : "",
  "explaintext" : "",
  "titles" : flowerName,
  “indexpageids” : "",
  "redirects" : "1", 
  ]
