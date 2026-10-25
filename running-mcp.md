# Local

## We establish a session
SESSION_ID=$(curl -s -D - -o /dev/null http://localhost:3000/mcp \
	-H "Accept: application/json, text/event-stream" \
	--json '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}' \
	| grep -i "^mcp-session-id:" | cut -d' ' -f2 | tr -d '\r')
	

## We check we're authenticated
curl -i http://localhost:3000/mcp \
	-H "Accept: application/json, text/event-stream" \
	-H "Mcp-Session-Id: $SESSION_ID" \
	--json '{"jsonrpc":"2.0","method":"notifications/initialized"}'
	

## We list the tools
curl http://localhost:3000/mcp \
	-H "Accept: application/json, text/event-stream" \
	-H "Mcp-Session-Id: $SESSION_ID" \
	--json '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

## The tools

### We list the Parliament periods with elections data
curl -i http://localhost:3000/mcp \
	 -H "Accept: application/json, text/event-stream" \
	 -H "Mcp-Session-Id: $SESSION_ID" \
	 --json '{"jsonrpc":"2.0","method":"tools/call","id":1,"params":{"name":"parliament_periods"}}'
	 
	 
# Staging

## We establish a session
SESSION_ID=$(curl -s -D - -o /dev/null https://psephology-test-72dc15bebb5d.herokuapp.com/mcp \
-H "Accept: application/json, text/event-stream" \
--json '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}' \
| grep -i "^mcp-session-id:" | cut -d' ' -f2 | tr -d '\r')


## We check we're authenticated
curl -i https://psephology-test-72dc15bebb5d.herokuapp.com/mcp \
-H "Accept: application/json, text/event-stream" \
-H "Mcp-Session-Id: $SESSION_ID" \
--json '{"jsonrpc":"2.0","method":"notifications/initialized"}'


## We list the tools
curl https://psephology-test-72dc15bebb5d.herokuapp.com/mcp \
-H "Accept: application/json, text/event-stream" \
-H "Mcp-Session-Id: $SESSION_ID" \
--json '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

## The tools

### We list the Parliament periods with elections data
curl -i https://psephology-test-72dc15bebb5d.herokuapp.com/mcp \
 -H "Accept: application/json, text/event-stream" \
 -H "Mcp-Session-Id: $SESSION_ID" \
 --json '{"jsonrpc":"2.0","method":"tools/call","id":1,"params":{"name":"parliament_periods"}}'
 
# Live

## We establish a session
SESSION_ID=$(curl -s -D - -o /dev/null https://electionresults.parliament.uk/mcp \
-H "Accept: application/json, text/event-stream" \
--json '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}' \
| grep -i "^mcp-session-id:" | cut -d' ' -f2 | tr -d '\r')


## We check we're authenticated
curl -i https://electionresults.parliament.uk/mcp \
-H "Accept: application/json, text/event-stream" \
-H "Mcp-Session-Id: $SESSION_ID" \
--json '{"jsonrpc":"2.0","method":"notifications/initialized"}'


## We list the tools
curl https://electionresults.parliament.uk/mcp \
-H "Accept: application/json, text/event-stream" \
-H "Mcp-Session-Id: $SESSION_ID" \
--json '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

## The tools

### We list the Parliament periods with elections data
curl -i https://electionresults.parliament.uk/mcp \
-H "Accept: application/json, text/event-stream" \
-H "Mcp-Session-Id: $SESSION_ID" \
--json '{"jsonrpc":"2.0","method":"tools/call","id":1,"params":{"name":"parliament_periods"}}'


