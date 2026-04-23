[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared green_tripdata_2022 = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "de1192df-b4de-4da0-b02b-18050efb45d2"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "a7b2836d-0fb6-4c38-adc6-075d7da499c2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "green_tripdata_2022", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"lpep_pickup_datetime", type date}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type", each ([store_and_fwd_flag] = "Y")),
  #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each [lpep_pickup_datetime] >= #date(2022, 1, 1) and [lpep_pickup_datetime] <= #date(2022, 1, 31)),
  #"Filtered rows 2" = Table.SelectRows(#"Filtered rows 1", each [PULocationID] = PUlocationID)
in
  #"Filtered rows 2";
shared nyc_taxi_green_discounts = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "de1192df-b4de-4da0-b02b-18050efb45d2"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "a7b2836d-0fb6-4c38-adc6-075d7da499c2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "nyc_taxi_green_discounts", ItemKind = "Table"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 2", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"VendorID", Int64.Type}, {"2015-01-01", Int64.Type}, {"2015-01-02", Int64.Type}, {"2015-01-03", Int64.Type}, {"2015-01-04", Int64.Type}, {"2015-01-05", Int64.Type}, {"2015-01-06", Int64.Type}, {"2015-01-07", Int64.Type}, {"2015-01-08", Int64.Type}, {"2015-01-09", Int64.Type}, {"2015-01-10", Int64.Type}, {"2015-01-11", Int64.Type}, {"2015-01-12", Int64.Type}, {"2015-01-13", Int64.Type}, {"2015-01-14", Int64.Type}, {"2015-01-15", Int64.Type}, {"2015-01-16", Int64.Type}, {"2015-01-17", Int64.Type}, {"2015-01-18", Int64.Type}, {"2015-01-19", Int64.Type}, {"2015-01-20", Int64.Type}, {"2015-01-21", Int64.Type}, {"2015-01-22", Int64.Type}, {"2015-01-23", Int64.Type}, {"2015-01-24", Int64.Type}, {"2015-01-25", Int64.Type}, {"2015-01-26", Int64.Type}, {"2015-01-27", Int64.Type}, {"2015-01-28", Int64.Type}, {"2015-01-29", Int64.Type}, {"2015-01-30", Int64.Type}, {"2015-01-31", Int64.Type}}),
  #"Unpivoted other columns" = Table.UnpivotOtherColumns(#"Changed column type", {"VendorID"}, "Date", "Discount"),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Unpivoted other columns", {{"Date", type date}}),
  #"Inserted division" = Table.AddColumn(#"Changed column type 1", "Division", each [Discount] / 100, type number)
in
  #"Inserted division";
shared PUlocationID = 244 meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type number];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "output_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "VendorID", DestinationColumnName = "VendorID"], [SourceColumnName = "lpep_pickup_datetime", DestinationColumnName = "lpep_pickup_datetime"], [SourceColumnName = "lpep_dropoff_datetime", DestinationColumnName = "lpep_dropoff_datetime"], [SourceColumnName = "store_and_fwd_flag", DestinationColumnName = "store_and_fwd_flag"], [SourceColumnName = "PULocationID", DestinationColumnName = "PULocationID"], [SourceColumnName = "DOLocationID", DestinationColumnName = "DOLocationID"], [SourceColumnName = "fare_amount", DestinationColumnName = "fare_amount"], [SourceColumnName = "extra", DestinationColumnName = "extra"], [SourceColumnName = "mta_tax", DestinationColumnName = "mta_tax"], [SourceColumnName = "tip_amount", DestinationColumnName = "tip_amount"], [SourceColumnName = "tolls_amount", DestinationColumnName = "tolls_amount"], [SourceColumnName = "ehail_fee", DestinationColumnName = "ehail_fee"], [SourceColumnName = "improvement_surcharge", DestinationColumnName = "improvement_surcharge"], [SourceColumnName = "total_amount", DestinationColumnName = "total_amount"], [SourceColumnName = "payment_type", DestinationColumnName = "payment_type"], [SourceColumnName = "trip_type", DestinationColumnName = "trip_type"], [SourceColumnName = "congestion_surcharge", DestinationColumnName = "congestion_surcharge"], [SourceColumnName = "source_file", DestinationColumnName = "source_file"], [SourceColumnName = "Date", DestinationColumnName = "Date"], [SourceColumnName = "Discount", DestinationColumnName = "Discount"], [SourceColumnName = "Division", DestinationColumnName = "Division"], [SourceColumnName = "TotalAfterDiscount", DestinationColumnName = "TotalAfterDiscount"], [SourceColumnName = "Inserted rounding", DestinationColumnName = "Inserted rounding"]}], DynamicSchema = true, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared output = let
  Source = Table.NestedJoin(green_tripdata_2022, {"VendorID"}, nyc_taxi_green_discounts, {"VendorID"}, "nyc_taxi_green_discounts", JoinKind.Inner),
  #"Expanded nyc_taxi_green_discounts" = Table.ExpandTableColumn(Source, "nyc_taxi_green_discounts", {"Date", "Discount", "Division"}, {"Date", "Discount", "Division"}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Expanded nyc_taxi_green_discounts", "TotalAfterDiscount", each if [tolls_amount] > 0 then [tolls_amount] * ( 1 - [Discount] ) else [tolls_amount]), {{"TotalAfterDiscount", Currency.Type}}),
  #"Inserted rounding" = Table.AddColumn(#"Added custom", "Inserted rounding", each Number.Round([TotalAfterDiscount], 2), type number),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted rounding", {{"lpep_pickup_datetime", type datetime}})
in
  #"Changed column type";
shared output_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, PreserveOrder = null]),
  Navigation_1 = Pattern{[workspaceId = "de1192df-b4de-4da0-b02b-18050efb45d2"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "a7b2836d-0fb6-4c38-adc6-075d7da499c2"]}[Data],
  TableNavigation = Navigation_2{[Id = "output1", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
