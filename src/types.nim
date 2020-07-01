type
  Metadata* = object of RootObj
    tags*: seq[string]

  Post* = object of RootObj
    path*, title*, date*, content*: string
    metadata*: Metadata

  ParseMetadataError* = object of ValueError
