locals {
  vertex_ai_common_tags = {
    service = "GCP/VertexAI"
  }
}

category "vertex_ai_endpoint" {
  title = "Vertex AI Endpoint"
  color = local.database_color
  icon  = "light"
}

category "vertex_ai_model" {
  title = "Vertex AI Model"
  color = local.database_color
  icon  = "lightbulb"
}