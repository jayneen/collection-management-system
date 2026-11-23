$(function () {
    const params = new URLSearchParams(location.search);
    const type = params.get('type');
    const uid = params.get('uid');
    const cfg = ENTITIES[type];

    if (!cfg || !uid) {
        $('#detailMsg').text('Missing or unknown type or uid.');
        return;
    }

    document.title = cfg.singular + ' Details';
    $('#detailTitle').text(cfg.singular + ' Details');
    $('#backLink').attr('href', `list.html?type=${type}`).text(`Back to All ${cfg.title}`);

    $.getJSON(`${cfg.endpoint}/${encodeURIComponent(uid)}`)
        .done(function (data) {
            const row = Array.isArray(data) ? data[0] : data;   // works whether the API returns one object or a one-item array
            if (!row) { $('#detailMsg').text('Record not found.'); return; }

            const $body = $('#viewTable tbody').empty();
            (cfg.fields || cfg.columns).forEach(f => {
                $body.append($('<tr>').append(
                    $('<td>').text(f.label),
                    $('<td>').text(f.value(row))
                ));
            });
        })
        .fail(function (xhr) {
            $('#detailMsg').text(xhr.responseJSON?.Error || 'Could not load this record.');
        });
});