$(document).on('click', '#quitBtn', function () {

    $.ajax({ url: 'http://127.0.0.1:2000/shutdown', method: 'POST' })
        .always(function () {
            $('body').html(
                '<div class="container mt-5"><h4>Application stopping.</h4>'
            );
        });
});