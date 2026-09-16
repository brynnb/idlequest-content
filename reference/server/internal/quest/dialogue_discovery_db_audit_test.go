package quest

import (
	"context"
	"database/sql"
	"encoding/json"
	"net"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/require"
	"github.com/yuin/gopher-lua/ast"
	"github.com/yuin/gopher-lua/parse"
)

// Read-only local corpus classification. Enabled script is not proof of an
// eligible world spawn or era: keep those dependencies separate in the report.
func TestAuditLocalEnabledDialogueShapes(t *testing.T) {
	if os.Getenv("IDLEQUEST_E2E_CONTENT_AUDIT") != "true" || os.Getenv("IDLEQUEST_LOCAL_DB_AUDIT") != "true" {
		t.Skip("requires explicit content and local database audit opt-ins")
	}
	host := os.Getenv("DB_HOST")
	require.Contains(t, []string{"127.0.0.1", "localhost", "::1"}, host, "local database only")
	port := os.Getenv("DB_PORT")
	if port == "" {
		port = "3306"
	}
	config := mysql.NewConfig()
	config.Net, config.Addr = "tcp", net.JoinHostPort(host, port)
	config.User, config.Passwd, config.DBName = os.Getenv("DB_USER"), os.Getenv("DB_PASS"), os.Getenv("DB_NAME")
	require.NotEmpty(t, config.DBName)
	connection, err := sql.Open("mysql", config.FormatDSN())
	require.NoError(t, err)
	defer connection.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	rows, err := connection.QueryContext(ctx, "SELECT zone, name, lua_content FROM quests WHERE enabled = 1 AND lua_content IS NOT NULL ORDER BY zone, name")
	require.NoError(t, err)
	defer rows.Close()
	report := struct {
		Rows        int                         `json:"enabledRows"`
		SayHandlers int                         `json:"namedSayHandlers"`
		Unparsed    []string                    `json:"parseFailures"`
		Assigned    []string                    `json:"assignedHandlers"`
		Nested      map[string][]string         `json:"nestedMessageConditions"`
		Shapes      map[string]map[string][]int `json:"messageAccessShapes"`
	}{Nested: map[string][]string{}, Shapes: map[string]map[string][]int{}}
	for rows.Next() {
		var zone, name, source string
		require.NoError(t, rows.Scan(&zone, &name, &source))
		report.Rows++
		key := zone + "/" + name
		chunk, err := parse.Parse(strings.NewReader(normalizeLegacyTurnInCurrencySyntax(source)), key)
		if err != nil {
			report.Unparsed = append(report.Unparsed, key)
			continue
		}
		if shapes := classifyDialogueMessageAccess(chunk); len(shapes) > 0 {
			report.Shapes[key] = shapes
		}
		for _, stmt := range chunk {
			switch node := stmt.(type) {
			case *ast.FuncDefStmt:
				if id, ok := node.Name.Func.(*ast.IdentExpr); ok && id.Value == "event_say" {
					report.SayHandlers++
					if nested := nestedDialogueConditions(node.Func.Stmts, false); len(nested) > 0 {
						report.Nested[key] = nested
					}
				}
			case *ast.AssignStmt:
				for _, lhs := range node.Lhs {
					if id, ok := lhs.(*ast.IdentExpr); ok && id.Value == "event_say" {
						report.Assigned = append(report.Assigned, key)
					}
				}
			}
		}
	}
	require.NoError(t, rows.Err())
	data, err := json.Marshal(report)
	require.NoError(t, err)
	t.Log(string(data))
}
