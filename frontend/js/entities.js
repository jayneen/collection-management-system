const ENTITIES = {
    games: {
        title: 'Games',
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
        viewUrl: r => `game.html?uid=${encodeURIComponent(r.UID)}`,
        editUrl: r => `updateGame.html?uid=${encodeURIComponent(r.UID)}`
    },
    consoles: {
        title: 'Consoles',
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
        viewUrl: r => `console.html?uid=${encodeURIComponent(r.UID)}`,
        editUrl: r => `updateConsole.html?uid=${encodeURIComponent(r.UID)}`
    }
};