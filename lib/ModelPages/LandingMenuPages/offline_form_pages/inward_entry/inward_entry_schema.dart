class InwardEntrySchema {
  static const Map<String, dynamic> schema = {
    "transid": "inward_entry",
    "caption": "Inward Entry",
    "visible": true,
    "attachments": true,
//todo fld_category ==> setion field
    "fields": [
      {
        "order": "1",
        "fld_category": "Basic Info",
        "fld_name": "ubGeNo",
        "fld_caption": "UB G.E No",
        "fld_type": "c",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F"
      },
      {
        "order": "2",
        "fld_category": "Basic Info",
        "fld_name": "unit",
        "fld_caption": "Unit",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "datasource": "DS_UNIT"
      },
      {
        "order": "3",
        "fld_category": "Basic Info",
        "fld_name": "receiptDate",
        "fld_caption": "Receipt Date",
        "fld_type": "date",
        "data_type": "d",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F"
      },
      {
        "order": "4",
        "fld_category": "Basic Info",
        "fld_name": "vehicleNo",
        "fld_caption": "Vehicle No",
        "fld_type": "c",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F"
      },
      {
        "order": "5",
        "fld_category": "Supplier",
        "fld_name": "s1Name",
        "fld_caption": "S1 Name",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "datasource": "DS_SUPPLIER"
      },
      {
        "order": "6",
        "fld_category": "Supplier",
        "fld_name": "s1Dc",
        "fld_caption": "S1 DC",
        "fld_type": "c",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F"
      },
      {
        "order": "7",
        "fld_category": "Supplier",
        "fld_name": "s2District",
        "fld_caption": "S2 District",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "T",
        "datasource": "DS_DISTRICT"
      },
      {
        "order": "8",
        "fld_category": "Supplier",
        "fld_name": "s2Name",
        "fld_caption": "S2 Name",
        "fld_type": "c",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "T"
      },
      {
        "order": "9",
        "fld_category": "Bottle Details",
        "fld_name": "bottleType",
        "fld_caption": "Bottle Type",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "datasource": "DS_BOTTLE_TYPE"
      },
      {
        "order": "10",
        "fld_category": "Bottle Details",
        "fld_name": "bottleCapacity",
        "fld_caption": "Bottle Capacity",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "datasource": "DS_BOTTLE_CAPACITY"
      },
      {
        "order": "11",
        "fld_category": "Bottle Details",
        "fld_name": "bottlePerCrate",
        "fld_caption": "Bottle Per Bag / Crate",
        "fld_type": "dd",
        "data_type": "s",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "datasource": "DS_BOTTLE_PER_CRATE"
      },
      {
        "order": "12",
        "fld_category": "Bottle Details",
        "fld_name": "manufacturingDate",
        "fld_caption": "Manufacturing Date of Bottle",
        "fld_type": "date",
        "data_type": "d",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "T"
      },
      {
        "order": "13",
        "fld_category": "Weight",
        "fld_name": "loadedWeight",
        "fld_caption": "Loaded Truck Weight",
        "fld_type": "n",
        "data_type": "n",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "rules": ["calc_net_weight"]
      },
      {
        "order": "14",
        "fld_category": "Weight",
        "fld_name": "emptyWeight",
        "fld_caption": "Empty Truck Weight",
        "fld_type": "n",
        "data_type": "n",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "rules": ["calc_net_weight"]
      },
      {
        "order": "15",
        "fld_category": "Weight",
        "fld_name": "netWeight",
        "fld_caption": "Net Weight",
        "fld_type": "n",
        "data_type": "n",
        "hidden": "F",
        "readonly": "T",
        "allowempty": "F"
      },
      {
        "order": "16",
        "fld_category": "Quantity",
        "fld_name": "receivedBags",
        "fld_caption": "Received Bags / Crates",
        "fld_type": "n",
        "data_type": "n",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "rules": ["received_bags_logic"]
      },
      {
        "order": "17",
        "fld_category": "Quantity",
        "fld_name": "bagsToSample",
        "fld_caption": "Bags To Sample",
        "fld_type": "n",
        "data_type": "n",
        "hidden": "F",
        "readonly": "F",
        "allowempty": "F",
        "rules": ["bags_to_sample_logic"]
      }
    ],

    "fillgrids": {
      "grid_id": "sample_bags",
      "caption": "Sample Bag Details",
      "fields": [
        {
          "order": "1",
          "fld_name": "broken",
          "fld_caption": "Broken",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "2",
          "fld_name": "neck_chip",
          "fld_caption": "Neck Chip",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "3",
          "fld_name": "extra_dirty",
          "fld_caption": "Extra Dirty",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "4",
          "fld_name": "short",
          "fld_caption": "Short",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "5",
          "fld_name": "other_brand",
          "fld_caption": "Other Brand",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "6",
          "fld_name": "other_kf",
          "fld_caption": "Other KF",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "7",
          "fld_name": "torn_bags",
          "fld_caption": "Torn Bags",
          "fld_type": "n",
          "data_type": "n",
          "def_value": "0"
        },
        {
          "order": "8",
          "fld_name": "maf_date",
          "fld_caption": "Maf Date",
          "fld_type": "date",
          "data_type": "d",
          "def_value": ""
        },
        {
          "order": "9",
          "fld_name": "maf_year",
          "fld_caption": "Maf Year",
          "fld_type": "year",
          "data_type": "n",
          "def_value": ""
        }
      ]
    },

    "rules": {
      "calc_net_weight": {
        "actions": [
          {
            "type": "set_value",
            "target": "netWeight",
            "expression": "loadedWeight - emptyWeight"
          }
        ]
      },
      "received_bags_logic": {
        "actions": [
          {
            "type": "if",
            "condition": "receivedBags < 20",
            "then": [
              {"type": "clear_value", "target": "bagsToSample"},
              {"type": "clear_grid", "grid": "sample_bags"},
              {"type": "hide_grid_button"}
            ],
            "else": [
              {
                "type": "set_value",
                "target": "bagsToSample",
                "expression": "max(1, floor(receivedBags * 0.05))"
              }
            ]
          }
        ]
      },
      "bags_to_sample_logic": {
        "actions": [
          {
            "type": "if",
            "condition": "bagsToSample >= 1",
            "then": [
              {
                "type": "generate_grid",
                "grid": "sample_bags",
                "count": "bagsToSample"
              },
              {"type": "show_grid_button"},
              {"type": "open_grid_dialog"}
            ],
            "else": [
              {"type": "clear_grid", "grid": "sample_bags"},
              {"type": "hide_grid_button"}
            ]
          }
        ]
      }
    }
  };
}
