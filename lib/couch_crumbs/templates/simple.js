{ 
  "#view_name": {
    "map": "function(doc) { if (doc['type'] == '#view_type') { emit(doc['#view_property'], doc); } }"
  } 
}