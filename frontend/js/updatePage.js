$(function () {
    const params = new URLSearchParams(location.search);
    const type = params.get('type');
    const uid = params.get('uid');
    const cfg = ENTITIES[type];

    if (!cfg || !cfg.updateFields || !uid) {
        $('#update-msg').text('Missing or unknown type or uid.');
        return;
    }

    const label = cfg.singular || cfg.title;
    document.title = `Update ${label}`;
    $('#pageTitle').text(`Update ${label} Record`);
    $('#backLink').attr('href', `list.html?type=${type}`).text(`Back to All ${cfg.title}`);

    // Build the form from the config
    const optionLoads = [];
    cfg.updateFields.forEach(f => {
        const id = 'f_' + f.name;
        const $group = $(f.type === 'checkbox' ? '<div class="form-check mb-3">' : '<div class="form-group">');

        if (f.type === 'checkbox') {
            $group.append(
                $('<input type="checkbox" class="form-check-input">').attr({ id, name: f.name }),
                $('<label class="form-check-label">').attr('for', id).text(f.label)
            );
        } else {
            $group.append($('<label>').attr('for', id).text(f.label));
            if (f.type === 'select') {
                const $select = $('<select class="form-control">').attr({ id, name: f.name })
                    .append($('<option value="">').text('Select ' + f.label.toLowerCase()));
                optionLoads.push($.getJSON(f.optionsUrl).done(items => {
                    items.filter(Boolean).forEach(item => $select.append($('<option>').val(item).text(item)));
                }));
                $group.append($select);
            } else {
                $group.append($('<textarea class="form-control" rows="4">').attr({ id, name: f.name }));
            }
        }
        $('#fields').append($group);
    });

    // Fill in the current values once the dropdown options exist
    $.when(...optionLoads).done(function () {
        $.getJSON(`${cfg.endpoint}/${encodeURIComponent(uid)}`).done(function (data) {
            const r = Array.isArray(data) ? data[0] : data;
            if (!r) { $('#update-msg').text('Record not found.'); return; }

            $('#recordName').text(r[cfg.nameKey] ?? '');
            cfg.updateFields.forEach(f => {
                const $el = $('#f_' + f.name);
                if (f.type === 'checkbox') $el.prop('checked', !!Number(r[f.key]));
                else $el.val(r[f.key] ?? '');
            });
        });
    });

    function show(kind, msg) {
        $('#update-msg').empty().append($('<div class="alert">').addClass('alert-' + kind).text(msg));
    }

    $('#update-form').on('submit', function (e) {
        e.preventDefault();
        const body = { uid };
        cfg.updateFields.forEach(f => {
            const $el = $('#f_' + f.name);
            body[f.name] = f.type === 'checkbox' ? ($el.is(':checked') ? 1 : 0) : $el.val();
        });

        $.ajax({ url: cfg.endpoint, method: 'PUT', contentType: 'application/json', data: JSON.stringify(body) })
            .done(() => show('info', `Record for ${$('#recordName').text()} has been successfully updated.`))
            .fail(xhr => show('danger', 'Error occurred: ' + (xhr.responseJSON?.Error || 'Could not reach the server')));
    });
});