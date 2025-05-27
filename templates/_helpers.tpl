{{- define "n8n.name" -}}n8n{{- end }}
{{- define "n8n.fullname" -}}{{ include "n8n.name" . }}-{{ .Release.Name }}{{- end }}