# redmine_destination_bbs_plugin
行先掲示板プラグイン

## API Usage

### Update a Destination Board Record

You can update a destination board record by sending a `PUT` request to the following endpoint:

`/redmine_destination_bbs/:id.api`

You must include your Redmine API key as a request header `X-Redmine-API-Key` or as a `key` parameter in the request body.

**Parameters:**

The request body should contain the `redmine_destination_bbs_model` object with the fields you want to update.

*   `destination` (string)
*   `start_time` (datetime)
*   `end_time` (datetime)
*   `comment` (text)
*   `attendance_location` (string)

**Example using cURL:**

```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: YOUR_API_KEY" \
  -d '{
        "redmine_destination_bbs_model": {
          "destination": "Working from home",
          "comment": "Focusing on the new feature"
        }
      }' \
  http://your-redmine-instance/redmine_destination_bbs/1.api
```
