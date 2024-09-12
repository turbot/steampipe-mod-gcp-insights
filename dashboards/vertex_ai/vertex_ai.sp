locals {
  vertex_ai_common_tags = {
    service = "GCP/VertexAI"
  }
}

category "vertex_ai_endpoint" {
  title = "Vertex AI Endpoint"
  color = local.database_color
  href  = "/gcp_insights.dashboard.vertex_ai_endpoint_detail?input.endpoint_id={{.properties.'ID' | @uri}}"
  icon  = "light"
}

category "vertex_ai_model" {
  title = "Vertex AI Model"
  color = local.database_color
  href  = "/gcp_insights.dashboard.vertex_ai_model_detail?input.model_id={{.properties.'ID' | @uri}}"
  icon  = "lightbulb"
}