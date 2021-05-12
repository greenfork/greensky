type
  Metadata* = object of RootObj
    tags*: seq[string]
    title*: string
    updatedAt*: string

  Post* = object of RootObj
    path*, title*, date*, content*: string
    metadata*: Metadata

  ParseMetadataError* = object of ValueError
