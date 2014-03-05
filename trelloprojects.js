var tags = [ "foo", "bar", "baz" ];

$(function() {
  $('.js-toggle-label-filter, .js-select-member, .js-due-filter, .js-clear-all').live('mouseup', showLabels);
  $('.js-input').live('keyup', showLabels);
  showLabels();
});

document.body.addEventListener('DOMNodeInserted', function(e) {
  if (e.target.id == 'board')
    setTimeout(showLabels);
  else if ($(e.target).hasClass('list'))
    showLabels();
});

var labelTimeout;
function showLabels() {
  clearTimeout(labelTimeout);
  labelTimeout = setTimeout(function() {
    $('.list').each(function() {
      if (!this.list)
        new List(this);
    });
  });
}

function List(el) {
  if (el.list)
    return;
  el.list = this;

  var $list = $(el);
  var busy = false;
  var to;
  var to2;

  function readCard($c) {
    if ($c.target) {
      if (!/list-card/.test($c.target.className))
        return;
      $c = $($c.target).filter('.list-card:not(.placeholder)');
    }
    $c.each(function() {
      if (!this.listCard)
        new ListCard(this);
      else
        setTimeout(this.listCard.refresh);
    });
  }

  $list.on('DOMNodeInserted', readCard);

  setTimeout(function() {
    readCard($list.find('.list-card'));
  });
}

function ListCard(el) {
  if (el.listCard)
    return;
  el.listCard = this;

  var regexp = /\{([^{}]+)\}/;
  var label = -1;
  var parsed;
  var that = this;
  var busy = false;
  var ptitle = '';
  var $card = $(el);
  var to;
  var to2;
  var tag;

  this.refresh = function() {
    if (busy)
      return;
    busy = true;

    $card.find(".project").remove();

    clearTimeout(to);
    to = setTimeout(function() {
      var $title = $card.find('a.list-card-title');
      if(!$title[0])
        return;

      var title = $title[0].childNodes[1].textContent;
      if (title)
        el._title = $title;

      if (title != ptitle) {
        ptitle = title;
        parsed = title.match(regexp);
        label = parsed ? parsed : -1;
      }

      clearTimeout(to2);

      to2 = setTimeout(function() {
        function recursiveReplace() {
          if (label != -1) {
            tags.forEach(function(text) {
              if (text === label[1]) tag = text;
            });
            $('<div class="badge '+ tag + '" />').text(that.label[1]).prependTo($card.find('.badges'));
            $title[0].childNodes[1].textContent = el._title = $.trim(el._title[0].text.replace(label[0],''));
            parsed = el._title.match(regexp);
            label = parsed ? parsed : -1;
            if (label != -1) {
              el._title = $title;
              recursiveReplace();
            }
          }
        }
        recursiveReplace();

        var list = $card.closest('.list');
        busy = false;
      });
    });
  };


  this.__defineGetter__('label', function() {
    return parsed ? label : '';
  });

  el.addEventListener('DOMNodeInserted', function(e) {
    if (/card-short-id/.test(e.target.className) && !busy) that.refresh();
    if ($('.badge').length > 0)
      $('.badge').hover(function handlerIn() {
        $('.list-card-details').each(function(i1, cards) {
          var badgeList = $(cards).find($('.badge'));
          $(badgeList).each(function(i2, badge) {
            var c;
            var className;
            var classes = $(badge)[0].classList;
            $(classes).each(function(i3, className) {
              tags.forEach(function(tag) {
                if (tag === className) {
                  if (className == event.target.innerText) {
                    // We are dealing with the same tag as the one hovered over
                  } else {
                    // We are dealing with cards which don't have the same tag
                    var otherCard = $($(badgeList)[i2])[0].parentNode.parentNode;
                    $(otherCard).css({"opacity": 0.2, "background": "rgba(0,0,0,0.5)"});
                  }
                }
              });
            });
          });
        });
      }, function handlerOut() {
          $('.list-card-details').each(function(i1, cards) {
          var badgeList = $(cards).find($('.badge'));
          $(badgeList).each(function(i2, badge) {
            var c;
            var className;
            var classes = $(badge)[0].classList;
            $(classes).each(function(i3, className) {
              tags.forEach(function(tag) {
                if (tag === className) {
                  if (className == event.target.innerText) {
                    // We are dealing with the same tag as the one hovered over
                  } else {
                    // We are dealing with cards which don't have the same tag
                    var otherCard = $($(badgeList)[i2])[0].parentNode.parentNode;
                    $(otherCard).css({"opacity": 1.0, "background": "#fff"});
                  }
                }
              });
            });
          });
        });
      });
  });

  setTimeout(that.refresh);
}
