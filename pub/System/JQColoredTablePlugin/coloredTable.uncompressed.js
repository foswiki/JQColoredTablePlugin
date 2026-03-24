/*
 * ColoredTable 
 *
 * Copyright (c) 2024-2026 Michael Daum http://michaeldaumconsulting.com
 *
 * Licensed under the GPL licenses http://www.gnu.org/licenses/gpl.html
 *
 */

"use strict";
(function($) {

  // Create the defaults once
  $.ColoredTable = {
    defaults: {
      select: null,
      highlight: null,
      keywords: [],
      styles: [],
      classes: [],
      caseSensitive: false,
      checkType: "string",
      dateFormat: ["DD MMM YYYY", "DD MMM YYYY hh:mm"],
      defaultStyles: null,
      defaultClasses: null,
    },
    autoSelect: null
  };

  // The actual plugin constructor
  function ColoredTable(elem, opts) {
    var self = this;

    self.elem = $(elem);

    self.opts = $.extend({}, $.ColoredTable.defaults, self.elem.data(), opts);
    self.init();
  }

  ColoredTable.prototype.init = function () {
    var self = this;

    if (self.opts.select) {
      self.table = $(self.opts.select);
    } else {
      self.table = self.elem;
    }
    self.regexes = [];

    // init regexes
    if (self.opts.checkType === 'regex') {
      self.opts.keywords.forEach(function(kw) {
        self.regexes.push(new RegExp(kw, self.opts.caseSensitive?"":"i"));
      });
    }

    // init inits
    else if (self.opts.checkType === 'integer') {
      self.integers = [];
      self.opts.keywords.forEach(function(kw) {
        self.integers.push(parseInt(kw, 10));
      });
    }

    // init floats
    else if (self.opts.checkType === 'float' 
      || self.opts.checkType === 'gt'
      || self.opts.checkType === 'lt'
    ) {
      self.floats = [];
      self.opts.keywords.forEach(function(kw) {
        self.floats.push(parseFloat(kw));
      });
    }

    // init dates
    else if (self.opts.checkType === "date"
      || self.opts.checkType === 'before'
      || self.opts.checkType === 'after'
    ) {
      self.dates = [];
      self.opts.keywords.forEach(function(kw) {
        self.dates.push(moment(kw, self.opts.dateFormat).valueOf());
      });
    }

    self.elem.on("change, refresh, reload", function() {
      self.colorize();
    });
    $(document).on("reload, afterReload.metadata", function() {
      self.colorize();
    });

    self.colorize();
  };

  ColoredTable.prototype.colorize = function() {
    var self = this;

    self.table.find("td").each(function() {
      var elem = $(this), 
          text = elem.text().trim();

      // check regex
      if (self.opts.checkType === 'regex') {
        for (var i = 0; i < self.regexes.length; i++) {
          if (self.regexes[i].test(text)) {
            self.styleElement(elem, i);
            break;
          }
        }
      } 

      // check string
      else if (self.opts.checkType === 'string') {
        if (!self.opts.caseSensitive) {
          text = text.toLowerCase();
        }
        for (var i = 0; i < self.opts.keywords.length; i++) {
          if (self.opts.keywords[i] === text) {
            self.styleElement(elem, i);
            break;
          }
        }
      } 

      // check int
      else if (self.opts.checkType === 'integer') {
        var val = parseInt(text, 10);
        for (var i = 0; i < self.integers.length; i++) {
          if (self.integers[i] == val) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check float
      else if (self.opts.checkType === 'float') {
        var val = parseFloat(text);
        for (var i = 0; i < self.floats.length; i++) {
          if (self.floats[i] == val) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check gt
      else if (self.opts.checkType === 'gt') {
        var val = parseFloat(text);
        for (var i = 0; i < self.floats.length; i++) {
          if (val > self.floats[i]) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check lt
      else if (self.opts.checkType === 'lt') {
        var val = parseFloat(text);
        for (var i = 0; i < self.floats.length; i++) {
          if (val < self.floats[i]) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check date
      else if (self.opts.checkType === 'date') {
        var val = moment(text, self.opts.dateFormat).valueOf();
        for (var i = 0; i < self.dates.length; i++) {
          if (self.dates[i] == val) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check before
      else if (self.opts.checkType === 'before') {
        var val = moment(text, self.opts.dateFormat).valueOf();
        for (var i = 0; i < self.dates.length; i++) {
          if (val < self.dates[i]) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

      // check after
      else if (self.opts.checkType === 'after') {
        var val = moment(text, self.opts.dateFormat).valueOf();
        for (var i = 0; i < self.dates.length; i++) {
          if (val > self.dates[i]) {
            self.styleElement(elem, i);
            break;
          }
        }
      }

    });
  };

  ColoredTable.prototype.styleElement = function(elem, i) {
    var self = this;

    if (self.opts.highlight && self.opts.highlight !== "this" ) {
      if (self.opts.highlight === "parent") {
        elem = elem.parent();
      } else if (self.opts.highlight === "next") {
        elem = elem.next();
      } else if (self.opts.highlight === "prev") {
        elem = elem.prev();
      } else {
        elem = elem.closest(self.opts.highlight);
      }
    }

    var style = "";
    if (self.opts.defaultStyles) {
      style = self.opts.defaultStyles+';';
    }

    if (self.opts.styles[i]) {
      elem.attr("style", style + self.opts.styles[i]);
    }

    if (self.opts.classes[i]) {
      elem.addClass(self.opts.classes[i]);
    }
  };

  // A plugin wrapper around the constructor,
  // preventing against multiple instantiations
  $.fn.coloredTable = function (opts) {
    return this.each(function () {
      if (!$.data(this, "coloredTable")) {
        $.data(this, "coloredTable", new ColoredTable(this, opts));
      }
    });
  };

  // Enable declarative widget instanziation
  $(function() {
    var selector = ".jqColoredTable";
    if ($.ColoredTable.autoSelect) {
      selector += ", " + $.ColoredTable.autoSelect;
    }
    $(selector).livequery(function() {
      $(this).coloredTable();
    });
  });

})(jQuery);
