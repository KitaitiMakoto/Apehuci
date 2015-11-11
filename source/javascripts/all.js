//= require_tree .

document.addEventListener("DOMContentLoaded", function(event) {
  if (document.body.classList.contains("index")) {
    var articles = document.getElementsByTagName("article");
    var index, article, offsetTop;
    for (index in articles) {
      article = articles[index];
      article.style.top = article.offsetTop + "px";
    }
  }
});

document.addEventListener("WebComponentsReady", function(event) {
  if (document.body.classList.contains("index")) {
    var articles = document.getElementsByTagName("article");
    if (articles.length === 0) {
      return;
    }
    var index, article, offsetTop;
    for (index in articles) {
      index = parseInt(index);
      article = articles[index];
      article.style.position = "absolute";
      article.style.left = (index * 1) + "em";
      setTimeout(function(article, index) {
        article.style.top = (index * 9.5) + "em";
      }, index * 100, article, index);
    }
  }
});
