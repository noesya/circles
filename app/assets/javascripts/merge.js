document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("merge-search")
  var results = document.getElementById("merge-search-results")
  if (!input || !results) return

  var excludeId = input.dataset.excludeId
  var mergeUrl = input.dataset.mergeUrl
  var csrfMeta = document.querySelector('meta[name="csrf-token"]')
  var csrfToken = csrfMeta ? csrfMeta.content : ""
  var timer = null

  input.addEventListener("input", function () {
    clearTimeout(timer)
    var query = input.value.trim()

    if (query.length < 2) {
      results.innerHTML = ""
      return
    }

    timer = setTimeout(function () {
      fetch("/people/search.json?q=" + encodeURIComponent(query))
        .then(function (response) { return response.json() })
        .then(renderResults)
    }, 200)
  })

  document.addEventListener("click", function (event) {
    if (event.target !== input && !results.contains(event.target)) {
      results.innerHTML = ""
    }
  })

  function renderResults(people) {
    results.innerHTML = ""

    people
      .filter(function (person) { return String(person.id) !== excludeId })
      .forEach(function (person) { results.appendChild(buildResult(person)) })
  }

  function buildResult(person) {
    var li = document.createElement("li")
    var form = document.createElement("form")
    form.method = "post"
    form.action = mergeUrl

    form.appendChild(hiddenField("authenticity_token", csrfToken))
    form.appendChild(hiddenField("target_id", person.id))

    var button = document.createElement("button")
    button.type = "submit"
    button.className = "btn btn-link p-0"
    button.textContent = person.status ? person.name + " — " + person.status : person.name
    form.appendChild(button)

    form.addEventListener("submit", function (event) {
      if (!window.confirm("Fusionner avec " + person.name + " ? Cette action est irréversible.")) {
        event.preventDefault()
      }
    })

    li.appendChild(form)
    return li
  }

  function hiddenField(name, value) {
    var field = document.createElement("input")
    field.type = "hidden"
    field.name = name
    field.value = value
    return field
  }
})
