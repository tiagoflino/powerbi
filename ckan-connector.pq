let 
    /*  Please update the two parameters below, Resource_id and BaseURL according to the dataset you 
        want to connect. You can also play with RowsPerPage to increase performance, although I found 
        100 to be the best in my tests
    */

    Resource_id     = "45ceb7e8-59bd-4492-b107-8379752ea597",
    BaseUrl         = "https://data.sa.gov.au/data/api/3/action/datastore_search?resource_id=" & Resource_id,
    RowsPerPage     = 100, 
 

    GetJson = (Url) =>
        let RawData = Web.Contents(Url),
            Json    = Json.Document(RawData)
        in  Json,
 
    GetEntityCount  = () =>
        let Json    = GetJson(BaseUrl),
            Result  = Json[result],
            Count   = Result[total]
        in  Count,
 
    GetPage = (Index) =>
        let Url   = BaseUrl & "&offset=" & Text.From(Index) & "&limit=" & Text.From(RowsPerPage),
            Json  = GetJson(Url),
            Result = Json[result],
            Records = Result[records]
        in  Records,
 
    EntityCount = List.Max({ RowsPerPage, GetEntityCount() }),
    PageCount   = Number.RoundUp(EntityCount / RowsPerPage),
    PageIndices = List.Numbers(0,PageCount,RowsPerPage),
    Pages       = List.Transform(PageIndices, each GetPage(_)),
    Entities    = List.Union(Pages),
    Table       = Table.FromList(Entities, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    Table