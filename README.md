# barbican cookbook

# Requirements

This cookbook depends on the yum, Yum-epel cookbooks

# Usage

To create a Barbican API node use:

```
run_list = [
	"recipe[barbican::api]"
      ]
```

To create a Barbican Worker node use:

```
run_list = [
	"recipe[barbican::worker]"
      ]
```

If you want the API or Worker node to use chef search to discover your database and queue nodes, run the search_discovery recipe first. This populates node attributes with values retreived from a chef search.  You can specify custom search queries or use the defaults.

```
run_list = [
	"recipe[barbican::search_discovery]",
	"recipe[barbican::api]"
      ]
```

# Attributes

# Recipes

# Author

Author:: Rackspace, Inc. (<cloudkeep@googlegroups.com>)
