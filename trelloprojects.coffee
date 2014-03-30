tags = [ "foo", "bar", "baz" ]


showLabels = ->
  $(".list").each ->
    readCard $(this).find(".list-card")


readCard = ($c) ->
  if $c.target
    return unless /list-card/.test($c.target.className)
    $c = $($c.target).filter(".list-card:not(.placeholder)")
  $c.each ->
    if not @listCard then new ListCard(this) else @listCard.refresh()


ListCard = (el) ->
  return if el.listCard

  busy        = false
  label       = -1
  parsed      = undefined
  ptitle      = ""
  regexp      = /\{([^{}]+)\}/
  tagName     = undefined

  @refresh = ->
    recursiveReplace = ->
      tags.forEach (tag) ->
        if tag is label[1] then tagName = tag
      $("<div class=\"badge " + tagName + "\" />").text(label[1]).prependTo $(el).find(".badges")
      $title[0].childNodes[1].textContent = el._title = $.trim(el._title[0].text.replace(label[0], ""))
      parsed = el._title.match(regexp)
      label = (if parsed then parsed else -1)

      unless label is -1
        el._title = $title
        recursiveReplace()

    return if busy
    busy = true
    $(el).find(".project").remove()
    $title = $(el).find("a.list-card-title")

    return unless $title[0]
    title = $title[0].childNodes[1].textContent
    if title then el._title = $title

    unless title is ptitle
      ptitle = title
      parsed = title.match(regexp)
      label  = if parsed then parsed else -1

    recursiveReplace()
    busy = false

  @refresh()


$(".js-toggle-label-filter, .js-select-member, .js-due-filter, .js-clear-all").on "mouseup", showLabels
$(".js-input").on "keyup", showLabels


document.addEventListener "DOMNodeInserted", ->
  showLabels() if event.target.id is "board" or $(event.target).hasClass("list")
  if $(".badge").length > 0

    $(".badge").hover (handlerIn = ->

      allCards = $(".list-card-details")

      allCards.css
        background : "rgba(0,0,0,0.5)"
        opacity    : 0.2

      visibleCards = allCards.filter (i, card) ->
        $(card).find(".badge." + event.target.innerText).length > 0

      visibleCards.css
        background : "#fff"
        opacity    : 1.0

    ), handlerOut = ->
      $(".list-card-details").css
        background : "#fff"
        opacity    : 1.0


showLabels()
