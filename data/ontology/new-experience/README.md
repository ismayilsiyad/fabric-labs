# Lakeshore Retail: new ontology experience

Downloaded 7 October 2026 from Microsoft Fabric samples:
https://github.com/microsoft/fabric-samples/tree/main/docs-samples/iq/ontology/new-experience

Used by `build-retail-ontology.html`. These files are separate from the older five-file ontology scenario. The telemetry and operational records use August 2026 sample dates; they are not live readings.

- Six static CSVs: upload to LakeshoreStaticDataLH and load to delta tables.
- refrigeration_telemetry.csv: import to LakeshoreTelemetryDataEH as RefrigerationTelemetry.
- SalesReport.pbix: import to the lab workspace to create its report and semantic model.
