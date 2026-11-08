# Source data dictionary and import notes

The report describes a CSV imported as `dbo.Dispatch` and references the columns below in its T-SQL examples. The exact CSV file and authoritative schema are not included with the article. Confirm every column name and type during import; CSV header inference may differ.

| Column | Usage in project | Import guidance |
|---|---|---|
| `DispatchID` | Transaction identifier used in examples | Prefer a unique integer or text identifier; verify uniqueness before treating it as a key. |
| `ProductID` | Product lookup and joins | Preserve a consistent type in fact and dimension tables. |
| `ProductName` | Product description and Laptop Stand filter | Unicode text (`nvarchar`) is a safe SQL Server choice. |
| `CustomerID` | Customer lookup and joins | Preserve a consistent type and check for nulls. |
| `CustomerName` | Customer sorting and display | Unicode text (`nvarchar`) is a safe choice. |
| `Order_Date` | Calendar dimension and monthly analysis | Convert to `date` or `datetime2` after validating formats and locale. |
| `City`, `State` | Location lookup and filters | Unicode text; trim/standardize whitespace and spelling before grouping. |
| `Quantity` | Unit totals and quantity filters | Integer or suitable decimal depending on the source. |
| `SalesAmount` | Sales filters and aggregation | `decimal(p,s)` rather than floating point, after confirming currency precision and input formatting. |

## Important assumptions

- The article names the imported table `dbo.Dispatch` and shows these fields in SQL. This list documents those references, not a guarantee that every version of the source file uses the exact same headers.
- The scripts assume `SalesAmount` is numeric and `Order_Date` is convertible to a SQL Server date. If the CSV contains symbols, locale-specific date formats, or text placeholders, stage and clean the raw values before running aggregations.
- The SQL project groups locations using both city and state. Confirm standardized city/state values, since differences in spelling or whitespace can split one real-world location into multiple rows.
- No profit, discount, or cost columns are established by the article, so this repository does not compute profit or margin.
