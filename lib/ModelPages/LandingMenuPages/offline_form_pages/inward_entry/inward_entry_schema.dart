// class InwardEntrySchema {
//   static const Map<String, dynamic> schema = {
//     "transid": "inward_entry",
//     "caption": "Inward Entry",
//     "visible": true,
//     "attachments": true,
//     "fields": [
//       {
//         "order": "1",
//         "fld_category": "Basic Info",
//         "fld_name": "unit",
//         "fld_caption": "Unit",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_UNIT"
//       },
//       {
//         "order": "2",
//         "fld_category": "Basic Info",
//         "fld_name": "ubGeNo",
//         "fld_caption": "UB G.E No",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "3",
//         "fld_category": "Basic Info",
//         "fld_name": "receiptDateTime",
//         "fld_caption": "Receipt Date Time",
//         "fld_type": "date",
//         "data_type": "d",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "4",
//         "fld_category": "Basic Info",
//         "fld_name": "vehicleNo",
//         "fld_caption": "Vehicle No",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "5",
//         "fld_category": "Basic Info",
//         "fld_name": "s1Dc",
//         "fld_caption": "S1 DC",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "6",
//         "fld_category": "Supplier",
//         "fld_name": "s1Name",
//         "fld_caption": "S1 Name",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_SUPPLIER"
//       },
//       {
//         "order": "7",
//         "fld_category": "Supplier",
//         "fld_name": "s1State",
//         "fld_caption": "S1 State",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_STATE"
//       },
//       {
//         "order": "8",
//         "fld_category": "Supplier",
//         "fld_name": "s2District",
//         "fld_caption": "S2 District",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_DISTRICT"
//       },
//       {
//         "order": "9",
//         "fld_category": "Supplier",
//         "fld_name": "s2Name",
//         "fld_caption": "S2 Name",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "10",
//         "fld_category": "Timing",
//         "fld_name": "entryDate",
//         "fld_caption": "Entry Date",
//         "fld_type": "date",
//         "data_type": "d",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "11",
//         "fld_category": "Timing",
//         "fld_name": "entryTime",
//         "fld_caption": "Entry Time",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "12",
//         "fld_category": "Timing",
//         "fld_name": "exitDate",
//         "fld_caption": "Exit Date",
//         "fld_type": "date",
//         "data_type": "d",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "13",
//         "fld_category": "Timing",
//         "fld_name": "exitTime",
//         "fld_caption": "Exit Time",
//         "fld_type": "c",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "14",
//         "fld_category": "Weight",
//         "fld_name": "loadedWeight",
//         "fld_caption": "Loaded Truck (Tonne)",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "rules": ["calc_net_weight"]
//       },
//       {
//         "order": "15",
//         "fld_category": "Weight",
//         "fld_name": "emptyWeight",
//         "fld_caption": "Empty Truck (Tonne)",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "rules": ["calc_net_weight"]
//       },
//       {
//         "order": "16",
//         "fld_category": "Weight",
//         "fld_name": "netWeight",
//         "fld_caption": "Net Weight",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "T",
//         "allowempty": "F"
//       },
//       {
//         "order": "17",
//         "fld_category": "Bottle",
//         "fld_name": "bottleType",
//         "fld_caption": "Bottle Type",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_BOTTLE_TYPE"
//       },
//       {
//         "order": "18",
//         "fld_category": "Bottle",
//         "fld_name": "bottleCapacity",
//         "fld_caption": "Bottle Capacity",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_BOTTLE_CAPACITY"
//       },
//       {
//         "order": "19",
//         "fld_category": "Bottle",
//         "fld_name": "packingType",
//         "fld_caption": "Packing Type",
//         "fld_type": "dd",
//         "data_type": "s",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "datasource": "DS_PACKING_TYPE"
//       },
//       {
//         "order": "20",
//         "fld_category": "Bottle",
//         "fld_name": "bottlePerPacking",
//         "fld_caption": "Bottle Per Packing Type",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "21",
//         "fld_category": "Quantity",
//         "fld_name": "billed",
//         "fld_caption": "Billed",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "22",
//         "fld_category": "Quantity",
//         "fld_name": "received",
//         "fld_caption": "Received",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       },
//       {
//         "order": "23",
//         "fld_category": "Quantity",
//         "fld_name": "bagsToSample",
//         "fld_caption": "Bags To Sample",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F",
//         "rules": ["bags_to_sample_logic"]
//       },
//       {
//         "order": "24",
//         "fld_category": "Quantity",
//         "fld_name": "shortage",
//         "fld_caption": "Shortage",
//         "fld_type": "n",
//         "data_type": "n",
//         "hidden": "F",
//         "readonly": "F",
//         "allowempty": "F"
//       }
//     ],
//     "fillgrids": {
//       "grid_id": "sample_bags",
//       "caption": "Sample Bag Details",
//       "fields": [
//         {
//           "order": "1",
//           "fld_name": "broken",
//           "fld_caption": "Broken",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "2",
//           "fld_name": "neck_chip",
//           "fld_caption": "Neck Chip",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "3",
//           "fld_name": "extra_dirty",
//           "fld_caption": "Extra Dirty",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "4",
//           "fld_name": "short",
//           "fld_caption": "Short",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "5",
//           "fld_name": "other_brand",
//           "fld_caption": "Other Brand",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "6",
//           "fld_name": "other_kf",
//           "fld_caption": "Other KF",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "7",
//           "fld_name": "torn_bags",
//           "fld_caption": "Torn Bags",
//           "fld_type": "n",
//           "data_type": "n",
//           "def_value": "0"
//         },
//         {
//           "order": "8",
//           "fld_name": "maf_date",
//           "fld_caption": "Maf Date",
//           "fld_type": "date",
//           "data_type": "d",
//           "def_value": ""
//         },
//         {
//           "order": "9",
//           "fld_name": "maf_year",
//           "fld_caption": "Maf Year",
//           "fld_type": "year",
//           "data_type": "n",
//           "def_value": ""
//         }
//       ]
//     },
//   };
// }
