// geoblaze.js bundles an older georaster and replaces the global
// parseGeoraster when it loads. Keep georaster.min.js's version, which
// streams COGs correctly (the older one fails on some overview reads),
// for addCOG().
var parseGeorasterCOG = parseGeoraster;
