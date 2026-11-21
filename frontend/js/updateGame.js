$(function () {
    const params = new URLSearchParams(window.location.search);
    const uid = params.get('uid');
    const gameName = params.get('gameName');

    $.when(
        populateDropdown('/options/conditions', '#conditionSelect'),
        populateDropdown('/options/sealorcibs', '#sealOrCIBSelect')
    ).done(() => {
        if (uid) {
            $.get(`/games/${encodeURIComponent(uid)}`, function (data) {
                if (data.length > 0) {
                    const r = data[0];
                    $('#conditionSelect').val(r.Condition || "");
                    $('#sealOrCIBSelect').val(r.SealOrCIB || "");
                    $('#notesInput').val(r.Notes || "");
                }
            });
        }

        if (gameName) {
            $('#gameName').text(gameName);
        }
        if (uid) {
            $('#uidInput').val(uid);
        }

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
                url: '/games',
                method: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(formData),
                success: () => {
                    $('#update-msg').html(`Record for ${gameName} has been successfully updated.`);
                    $('#update-msg').html(`<div class="alert alert-info">Record for ${gameName} has been successfully updated.</div>`);
                    $('#update-msg').show();
                },
                error: (xhr) => {
                    $('#update-msg').html('<div class="alert alert-danger">Error occured: ' + xhr.responseJSON.Error + '</div>');
                    $('#update-msg').show();
                }

            });
        });
    });
});


function populateDropdown(url, selectId) {
    return $.get(url, function (data) {
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
