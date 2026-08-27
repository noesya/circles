document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("[data-nested-add]").forEach(function (button) {
    button.addEventListener("click", function () {
      var name = button.dataset.nestedAdd
      var container = document.querySelector('[data-nested-fields="' + name + '"]')
      var template = document.querySelector('[data-nested-template="' + name + '"]')
      if (!container || !template) return

      var index = new Date().getTime()
      var html = template.innerHTML.replace(/NEW_RECORD/g, index)
      var wrapper = document.createElement("div")
      wrapper.innerHTML = html.trim()
      container.appendChild(wrapper.firstElementChild)
    })
  })

  document.addEventListener("click", function (event) {
    var cancelButton = event.target.closest("[data-nested-cancel]")
    if (!cancelButton) return

    var item = cancelButton.closest("[data-nested-fields-item]")
    if (item) item.remove()
  })

  document.addEventListener("change", function (event) {
    var toggle = event.target.closest("[data-nested-obsolete-toggle]")
    if (!toggle) return

    var item = toggle.closest("[data-nested-fields-item]")
    if (!item) return

    var input = item.querySelector('input[type="text"]')
    if (!input) return

    input.classList.toggle("text-decoration-line-through", toggle.checked)
    input.classList.toggle("text-muted", toggle.checked)
  })
})
