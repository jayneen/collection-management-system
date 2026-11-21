$(function () {
    // suggestions with free entry
    setupAutocomplete('#modelNameInput', '/options/consoles');
    setupAutocomplete('#consolePublisherInput', '/options/consolepublishers');
    

    // submission
    $('#create-form').submit(function (e) {
        e.preventDefault();
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
            url: '/consoles/consolemodels',
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