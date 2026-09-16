import test from 'node:test';
import assert from 'node:assert/strict';
import { schemaColumns, sqlValue } from './migration.mjs';
import { sourceDestination, sourceEnabled, validateLedger } from './source-policy.mjs';

test('SQL literal encoding preserves quotes, newlines, Unicode, binary and large IDs',()=>{
  const value="it's\n雪; DROP TABLE x;";
  assert.equal(sqlValue(value),`CONVERT(X'${Buffer.from(value).toString('hex')}' USING utf8mb4)`);
  assert.equal(sqlValue({$binary:'AP8='}),"X'00ff'");
  assert.equal(sqlValue(null),'NULL');
  assert.throws(()=>sqlValue({unexpected:1}),/Unsupported/);
});
test('schema columns retain enum strings, unsigned types and nullability',()=>{
  assert.deepEqual(schemaColumns("CREATE TABLE `x` (\n  `id` tinyint(1) unsigned zerofill NOT NULL\n);"),[{name:'id',type:'tinyint(1) unsigned zerofill',nullable:false}]);
  assert.deepEqual(schemaColumns("CREATE TABLE `x` (\n  `body` text,\n  `id` int NOT NULL\n);"),[{name:'body',type:'text',nullable:true},{name:'id',type:'int',nullable:false}]);
  assert.deepEqual(schemaColumns("CREATE TABLE `x` (\n  `id` bigint unsigned NOT NULL,\n  `mode` enum('a ) b','low') DEFAULT NULL\n);"),[
    {name:'id',type:'bigint unsigned',nullable:false},
    {name:'mode',type:"enum('a ) b','low')",nullable:true},
  ]);
});
test('source destinations are bounded and enabled state belongs in headers',()=>{
  assert.equal(sourceDestination('maintained/modules/sub/items.lua'),'server/internal/quest/overrides/modules/sub/items.lua');
  assert.throws(()=>sourceDestination('maintained/modules/../private.lua'),/Unsafe/);
  assert.throws(()=>sourceDestination('reference/.env'),/Unsupported/);
  assert.equal(sourceEnabled('-- name: Alias\n-- enabled: false\nreturn {}'),false);
  assert.equal(sourceEnabled('return {}\n-- enabled: false'),true);
  assert.throws(()=>sourceEnabled('-- enabled: maybe'),/Invalid/);
  assert.throws(()=>validateLedger('reference/server/internal/contentscope/npc_exclusions.json','{"npcs":[{"id":1}]}'),/Invalid/);
});
