package main

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/stretchr/testify/require"
)

type directoryCleanupRecorder struct {
	query string
	args  []any
	err   error
}

func (r *directoryCleanupRecorder) ExecContext(_ context.Context, query string, args ...any) (sql.Result, error) {
	r.query, r.args = query, args
	return nil, r.err
}

func TestSourceDirectoryImportAndCleanupAgree(t *testing.T) {
	for _, name := range nonQuestSourceDirectories {
		require.False(t, isQuestSourceDirectory(name))
	}
	for _, name := range []string{"hole", "tox", "encounters", "necropolis"} {
		require.True(t, isQuestSourceDirectory(name))
	}
	r := &directoryCleanupRecorder{}
	require.NoError(t, disableNonQuestDirectoryRows(context.Background(), r))
	require.Equal(t, "UPDATE quests SET enabled = 0 WHERE enabled <> 0 AND zone IN (?,?,?,?)", r.query)
	require.Equal(t, []any{".git", "lua_modules", "plugins", "utility"}, r.args)
	r.err = errors.New("write failed")
	require.ErrorContains(t, disableNonQuestDirectoryRows(context.Background(), r), "write failed")
}
