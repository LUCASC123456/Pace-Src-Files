extends Node

const SUPABASE_URL := "https://worurlqcrzgpzmedykef.supabase.co/rest/v1"
const SUPABASE_KEY := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvcnVybHFjcnpncHptZWR5a2VmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MDgwNzksImV4cCI6MjA3NTM4NDA3OX0.Mfz8IoKFifb2_uCPdLI_RwosnUB0ekpreZisX7k-l4w"
const TABLE := "Leaderboard"

var leaderboard: Array = []

# -------------------------------
func httpRequest(url: String, method: int, body: Dictionary = {}) -> HTTPRequest:
	var http := HTTPRequest.new()
	add_child(http)
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Prefer: resolution=merge-duplicates"
	]
	var jsonBody := JSON.stringify(body)
	http.request(url, headers, method, jsonBody)
	return http

# -------------------------------
# Upload or update stats (original working version)
func uploadStats(player_id: String, stats: Dictionary) -> void:
	var url := SUPABASE_URL + "/" + TABLE + "?player_id=eq." + player_id
	var httpGet = httpRequest(url, HTTPClient.METHOD_GET)

	httpGet.request_completed.connect(func(result, responseCode, headers, body):
		httpGet.queue_free()

		if responseCode != 200:
			return
		else:
			pass

		var text = body.get_string_from_utf8()
		var parseResult = JSON.parse_string(text)
		var existing := {}
		if typeof(parseResult) == TYPE_ARRAY and parseResult.size() > 0:
			existing = parseResult[0]
		else:
			pass

		var updated := {
			"player_id": player_id,
			"level": int(max(stats.get("level", 0), existing.get("level", 0))),
			"best_time": int(min(stats.get("bestTime", INF), existing.get("best_time", INF))),
			"lowest_distance": int(min(stats.get("lowestDistance", INF), existing.get("lowest_distance", INF))),
			"least_damage": int(min(stats.get("leastDamage", INF), existing.get("least_damage", INF)))
		}

		var urlUpsert := SUPABASE_URL + "/" + TABLE + "?on_conflict=player_id"
		var httpPost = httpRequest(urlUpsert, HTTPClient.METHOD_POST, updated)
		httpPost.request_completed.connect(func(result2, responseCode2, headers2, body2):
			httpPost.queue_free()
			if responseCode2 in [200, 201]:
				# IMPORTANT: Fetch leaderboard *after* upload finishes
				fetchLeaderboard()
			else:
				pass
		)
	)
# -------------------------------

# Fetch leaderboard sorted by best_time, lowest_distance, least_damage
func fetchLeaderboard() -> void:
	var url := SUPABASE_URL + "/" + TABLE + "?select=*&order=best_time.asc&order=lowest_distance.asc&order=least_damage.asc"
	var http = httpRequest(url, HTTPClient.METHOD_GET)
	http.request_completed.connect(func(result, code, headers, body):
		http.queue_free()
		if code == 200:
			var text = body.get_string_from_utf8()
			var parseResult = JSON.parse_string(text)
			if typeof(parseResult) == TYPE_ARRAY:
				leaderboard = parseResult
			else:
				pass
		else:
			pass
	)
