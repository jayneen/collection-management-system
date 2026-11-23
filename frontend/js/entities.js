const ENTITIES = {
    games: {
        title: 'Games',
        singular: 'Game',
        endpoint: '/games',
        nameKey: 'GameName',
        searchKey: 'GameName',
        columns: [
            { label: 'UID', value: r => r.UID },
            { label: 'Game Name', value: r => r.GameName },
            { label: 'Region', value: r => r.Region },
            { label: 'Condition', value: r => [r.Condition, r.SealOrCIB === 'Neither' ? '' : r.SealOrCIB].filter(Boolean).join(' ') },
            { label: 'Notes', value: r => r.Notes ?? '' }
        ],
        fields: [
            { label: 'UID', value: r => r.UID },
            { label: 'Game Name', value: r => r.GameName },
            { label: 'Rating', value: r => r.Rating },
            { label: 'Region', value: r => r.Region },
            { label: 'Console Model', value: r => r.ModelName },
            { label: 'Series', value: r => r.Series },
            { label: 'Peripheral', value: r => r.PeripheralName },
            { label: 'Genres', value: r => r.Genres },
            { label: 'Condition', value: r => [r.Condition, r.SealOrCIB === 'Neither' ? '' : r.SealOrCIB].filter(Boolean).join(' ') },
            { label: 'Notes', value: r => r.Notes ?? '' }
        ],
        viewUrl: r => `detail.html?type=games&uid=${encodeURIComponent(r.UID)}`,
        editUrl: r => `updateGame.html?uid=${encodeURIComponent(r.UID)}`
    },
    consoles: {
        title: 'Consoles',
        singular: 'Console',
        endpoint: '/consoles',
        nameKey: 'ModelName',
        searchKey: 'ModelName',
        columns: [
            { label: 'UID', value: r => r.UID },
            { label: 'Model', value: r => r.ModelName },
            { label: 'Region', value: r => r.Region },
            { label: 'Condition', value: r => r.Condition },
            { label: 'Modded', value: r => (r.isModded ? 'Yes' : 'No') },
            { label: 'Notes', value: r => r.Notes ?? '' }
        ],
        fields: [
            { label: 'UID', value: r => r.UID },
            { label: 'Model', value: r => r.ModelName },
            { label: 'Region', value: r => r.Region },
            { label: 'Condition', value: r => r.Condition },
            { label: 'Seal / CIB', value: r => r.SealOrCIB },
            { label: 'Modded', value: r => (r.isModded ? 'Yes' : 'No') },
            { label: 'Notes', value: r => r.Notes ?? '' }
        ],
        viewUrl: r => `detail.html?type=consoles&uid=${encodeURIComponent(r.UID)}`,
        editUrl: r => `updateConsole.html?uid=${encodeURIComponent(r.UID)}`
    }
};