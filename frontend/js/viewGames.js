function loadTable(filter) {
  let url = '/games';
  if (filter) {
    url += '?name=' + encodeURIComponent(filter);
  }

  $.get(url, function (data) {

    if (!Array.isArray(data)) {
      console.error("Expected array, got:", data);
      return;
    }

    let rows = data.filter(r => !filter || r.GameName.toLowerCase().includes(filter));

    let html = rows.map(r => {
      let notes = r.Notes;
      if (notes === null) notes = "";
      let cond = r.SealOrCIB;
      if (cond === "Neither") cond = "";


      return `
      <tr>
        <td>${r.UID}</td>
        <td>${r.GameName}</td>
        <td>${r.Region}</td>
        <td>${r.Condition + " " + cond}</td>
        <td>${notes}</td>
        <td>
          <a href="game.html?uid=${encodeURIComponent(r.UID)}" class="btn btn-info btn-sm">View</a>
          <a href="updateGame.html?uid=${encodeURIComponent(r.UID)}&gameName=${encodeURIComponent(r.GameName)}" class="btn btn-warning btn-sm">Edit</a>
          <button class="btn btn-danger btn-sm del-btn" data-uid="${encodeURIComponent(r.UID)}" data-gamename="${r.GameName}">Delete</button>
        </td>
      </tr>
  `;
    }).join('');

    $('#tbl tbody').html(html);
  }).fail(function (xhr, status, error) {
    console.error("Failed to load games:", status, error);
  });
}


$(function () {
  loadTable('');
  $('#search').on('input', function () {
    loadTable(this.value.toLowerCase());
  });

  $(document).on('click', '.del-btn', function () {
    const name = $(this).data('gamename');
    const uid = $(this).data('uid');
    $('#modalMessage').text(`Are you sure you want to delete this record for ${name}?`);
    $('#confirmDel').data('uid', uid);
    $('#delModal').modal('show');
  });

  $('#confirmDel').click(function () {
    const uid = $(this).data('uid');
    $.ajax({
      url: '/games/' + encodeURIComponent(uid),
      method: 'DELETE',
      success: () => {
        alert("Record deleted successfully!");
        $('#delModal').modal('hide');
        loadTable($('#search').val().toLowerCase());
      },
      error: (xhr) => {
        $('#delMsg').html(`<div class="alert alert-warning">Error occurred: ${xhr.responseJSON.Error}</div>`);
      }
    });
  });
});
