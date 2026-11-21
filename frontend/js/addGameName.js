$(function () {
    // suggestions with free entry
    setupAutocomplete('#gameNameInput', '/options/gamenames');

    // selectors
    populateDropdown('/options/ratings', '#ratingSelect');

    // suggestions with free entry and infinite "add another"
    createDynamicInput('#genreContainer', '/options/genres', 'genre');
    createDynamicInput('#seriesContainer', '/options/series', 'series');
    createDynamicInput('#consoleContainer', '/options/consoles', 'consoles');

    // submission
    $('#create-form').submit(function (e) {
        e.preventDefault();
        // collect all entered data
        const formData = {};
        $('#create-form').serializeArray().forEach(({ name, value }) => {
            // Remove "[]" if present in input name
            const cleanName = name.replace(/\[\]$/, '');

            if (formData[cleanName]) {
                formData[cleanName].push(value);
            } else {
                formData[cleanName] = [value]; // Always make it an array
            }
        });


        $.ajax({
            url: '/games/gamenames',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(formData),
            success: function () {
                $('#create-msg').html(`<div class="alert alert-success">Record for a copy of ${formData.gameName} has been successfully created.</div>`);
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

function createDynamicInput(containerId, endpoint, inputName) {
    const container = $(containerId);

    function addField() {
        const index = container.children('.input-group').length;
        const inputId = inputName + '-' + index;

        const inputGroup = $(`
      <div class="input-group mb-2" data-index="${index}">
        <input type="text" class="form-control" name="${inputName}[]" id="${inputId}" autocomplete="off" placeholder="Enter a ${inputName}"/>
        <div class="input-group-append">
          <div class="input-group-text">
            <input type="checkbox" class="add-more-toggle" title="Add/remove field" />
          </div>
        </div>
      </div>
    `);

        container.append(inputGroup);

        // Autocomplete
        $.get(endpoint, function (data) {
            $(`#${inputId}`).autocomplete({
                source: data,
                minLength: 0
            }).on('focus', function () {
                $(this).autocomplete('search', '');
            });
        });

        // Add/change listener
        inputGroup.find('.add-more-toggle').on('change', function () {
            const isChecked = $(this).is(':checked');

            if (isChecked) {
                addField();
            } else {
                inputGroup.remove(); // remove the whole row
            }
        });
    }

    // Start with one field
    addField();
}
