{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If Ingress name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "n8n.deployment.apiVersion" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.GitVersion -}}
apps/v1
{{- else -}}
apps/v1beta2
{{- end }}
{{- end -}}

{{/*
Name of the encryption key secret.
*/}}
{{- define "n8n.encryptionKeySecretName" -}}
{{- .Values.config.existingEncryptionKeySecret | default (printf "%s-encryption-key" (include "n8n.fullname" .)) }}
{{- end -}}

{{/*
PostgreSQL Host
Assumes PostgreSQL is a sibling chart deployed with the release.
The service name for Bitnami PostgreSQL is typically <releaseName>-<chartName>
If postgresql.fullnameOverride is set for the postgresql subchart, that takes precedence.
*/}}
{{- define "n8n.postgresql.host" -}}
{{- $postgresqlFullname := printf "%s-postgresql" .Release.Name -}}
{{- $host := "" -}}
{{- if .Values.global -}}
  {{- if .Values.global.postgresql -}}
    {{- $host = .Values.global.postgresql.fullnameOverride | default $postgresqlFullname -}}
  {{- else -}}
    {{- $host = $postgresqlFullname -}}
  {{- end -}}
{{- else -}}
  {{- $host = $postgresqlFullname -}}
{{- end -}}
{{- $host -}}
{{- end -}}


{{/*
Redis Host
Assumes Redis is a sibling chart deployed with the release.
The service name for Bitnami Redis master is typically <releaseName>-<chartName>-master
If redis.fullnameOverride is set for the redis subchart, that takes precedence.
*/}}
{{- define "n8n.redis.host" -}}
{{- $redisFullname := printf "%s-redis-master" .Release.Name -}}
{{- $host := "" -}}
{{- if .Values.global -}}
  {{- if .Values.global.redis -}}
    {{- $host = .Values.global.redis.fullnameOverride | default $redisFullname -}}
  {{- else -}}
    {{- $host = $redisFullname -}}
  {{- end -}}
{{- else -}}
  {{- $host = $redisFullname -}}
{{- end -}}
{{- $host -}}
{{- end -}}