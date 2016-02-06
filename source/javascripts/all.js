//= require_tree .
document.addEventListener("DOMContentLoaded", function() {
  "use strict";

  setupSearch();

  function setupSearch() {
    var forms = document.querySelectorAll("form.search");
    var form;
    for (var i = 0, l = forms.length; i < l; i++) {
      form = forms[i];
      form.addEventListener("submit", function(event) {
        event.preventDefault();

        var request = new XMLHttpRequest();
        request.addEventListener("load", function(event) {
          console.debug(event.target.responseText);
          var result = JSON.parse(event.target.responseText);
        });
        var url = new URL(form.action);
        var params = [];
        var inputs = form.getElementsByTagName("input");
        console.log(inputs);
        var input;
        for (var j = 0, m = inputs.length; j < m; j++) {
          var input = inputs[i];
          console.log(input);
          if (! input.name) {
            continue;
          }
          params.push(input.name, '=', input.value);
        }
        url.search = params.join(";");
        request.open(form.method, url);
        request.send();
      });
    }
  };
});
