$(function () {
  // suggestions with free entry
  setupAutocomplete('#regionInput', '/options/regions');

  // selectors
  populateDropdown('/options/consoles', '#modelNameSelect');
  populateDropdown('/options/conditions', '#conditionSelect');
  populateDropdown('/options/sealorcibs', '#sealOrCIBSelect');

  // submission
  $('#create-form').submit(function (e) {
    e.preventDefault();
    const formData = {};
    $('#create-form').serializeArray().forEach(({ name, value }) => {
      if (formData[name]) {
        if (Array.isArray(formData[name])) {
          formData[name].push(value);
        } else {
          formData[name] = [formData[name], value];
        }
      } else {
        formData[name] = value;
      }
    });

    $.ajax({
      url: '/consoles',
      method: 'POST',
      contentType: 'application/json',
      data: JSON.stringify(formData),
      success: function () {
        $('#create-msg').html(`<div class="alert alert-success">Record for a copy of ${formData.modelName} has been successfully created.</div>`);
        $('#create-form')[0].reset();
      },
      error: function (xhr) {
        $('#create-msg').html('<div class="alert alert-danger">Error occurred: ' + xhr.responseJSON.Error + '</div>');
      }
    });
  });
});

function populateDropdown(url, selectId) {
  $.get(url, function (data) {
    const select = $(selectId);
    data.forEach(item => {
      if (item) {
        select.append(`<option value="${item}">${item}</option>`);
      }
    });
  }).fail(err => {
    console.error(`Error loading ${url}:`, err);
  });
}

function setupAutocomplete(id, endpoint) {
  $.get(endpoint, function (data) {
    $(id).autocomplete({
      source: data,
      minLength: 0
    }).on('focus', function () {
      $(this).autocomplete('search', '');
    });
  }).fail(function (err) {
    console.error(`Error loading data for ${id} from ${endpoint}`, err);
  });
}
