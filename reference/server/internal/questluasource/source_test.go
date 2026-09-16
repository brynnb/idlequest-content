package questluasource

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestValidationUsesRuntimeDialectWithoutExecuting(t *testing.T) {
	require.NoError(t, Validate("npc", "# legacy comment\nerror('must not execute')", false))
	require.Error(t, Validate("module", "# legacy comment\nreturn {}", true))
	require.Error(t, Validate("npc", "function broken(", false))
	require.NoError(t, Validate("npc", "local req={123, gold==5}", false))
}
