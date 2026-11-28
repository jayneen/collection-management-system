$(function () {
    const key = new URLSearchParams(location.search).get('form');
    const cfg = ADD_FORMS[key];

    if (!cfg) {
        $('#create-msg').text(`Unknown form: ${key}. Try: ${Object.keys(ADD_FORMS).join(', ')}`);
        return;
    }

    document.title = cfg.title;
    $('#pageTitle').text(cfg.title);
    $('#submitBtn').text(cfg.submitLabel);

    function buildForm() {
        const $fields = $('#fields').empty();
        cfg.fields.forEach(f => $fields.append(buildField(f)));
    }

    function show(kind, text) {
        $('#create-msg').empty()
            .append($('<div class="alert">').addClass('alert-' + kind).text(text));
    }

    buildForm();

    $('#create-form').on('submit', function (e) {
        e.preventDefault();

        const data = {};
        cfg.fields.forEach(f => {
            const value = readField(f);
            data[f.name] = cfg.arrays && !Array.isArray(value) ? [value] : value;
        });
        const name = $('#f_' + cfg.nameField).val();

        $.ajax({
            url: cfg.endpoint,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data)
        })
            .done(() => { show('success', cfg.success(name)); buildForm(); })
            .fail(xhr => show('danger',
                'Error occurred: ' + (xhr.responseJSON?.Error || 'Could not reach the server')));
    });
});