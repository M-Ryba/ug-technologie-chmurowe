"use strict";
var _ = require("lodash");
var array = ["Hello"];
var other = _.concat(array, "World", "!");
console.log(other);
console.log("NODE_ENV: ", process.env.NODE_ENV);
