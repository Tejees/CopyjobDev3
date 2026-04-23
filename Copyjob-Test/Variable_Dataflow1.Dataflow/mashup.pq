[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "holidaydatacontainer_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "countryOrRegion", DestinationColumnName = "countryOrRegion"], [SourceColumnName = "holidayName", DestinationColumnName = "holidayName"], [SourceColumnName = "normalizeHolidayName", DestinationColumnName = "normalizeHolidayName"], [SourceColumnName = "isPaidTimeOff", DestinationColumnName = "isPaidTimeOff"], [SourceColumnName = "countryRegionCode", DestinationColumnName = "countryRegionCode"], [SourceColumnName = "date", DestinationColumnName = "date"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared holidaydatacontainer = let
  Source = Lakehouse.Contents(null),

  // Filter workspace safely
  WorkspaceTable = Table.SelectRows(Source, each [workspaceId] = WorkspaceId),

  // Take first row
  WorkspaceData = WorkspaceTable{0}[Data],

  // Filter lakehouse
  LakehouseTable = Table.SelectRows(WorkspaceData, each [lakehouseId] = LakehouseId),

  LakehouseData = LakehouseTable{0}[Data],

  // Get table
  FinalTable = LakehouseData{[Id = "holidaydatacontainer", ItemKind = "Table"]}[Data],

  #"Filtered rows" = Table.SelectRows(FinalTable, each [countryOrRegion] = Region)
in
  #"Filtered rows";
shared WorkspaceId = let
  Source = Variable.ValueOrDefault("$(/**/dataflow-Variables/WorkspaceId)", "de1192df-b4de-4da0-b02b-18050efb45d2")
in
  Source;
shared LakehouseId = let
  LakehouseId = Variable.ValueOrDefault("$(/**/dataflow-Variables/LakehouseID)", "a7b2836d-0fb6-4c38-adc6-075d7da499c2")
in
  LakehouseId;
shared Region = let
  Source = Variable.ValueOrDefault("$(/**/dataflow-Variables/Region)", "Sweden")
in
  Source;
shared holidaydatacontainer_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "dataFactory_warehouse"]}[Data],
  TableNavigation = Navigation_2{[Item = "holidaydatacontainer", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
