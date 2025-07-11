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
{{- end }}

{{/*
Return the appropriate apiVersion for HPA.
Allows overriding via .Values.autoscaling.apiVersion
*/}}
{{- define "n8n.hpa.apiVersion" -}}
{{- $hpaValues := .Values.autoscaling | default dict -}}
{{- $apiVersion := $hpaValues.apiVersion | default "" -}}
{{- if $apiVersion -}}
    {{- $apiVersion -}}
{{- else if semverCompare ">=1.23-0" .Capabilities.KubeVersion.GitVersion -}}
autoscaling/v2
{{- else -}}
autoscaling/v2beta2
{{- end }}
{{- end }}


{{/*
Service Account Name
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- $createSA := $sa.create | default true -}}
{{- $saName := $sa.name | default "" -}}

{{- if $createSA -}}
  {{- $saName | default (include "n8n.fullname" .) -}}
{{- else -}}
  {{- $saName | default "default" -}}
{{- end }}
{{- end -}}

{{/*
Name of the encryption key secret.
Uses .Values.config.existingEncryptionKeySecret if provided from parent, otherwise generates a name.
*/}}
{{- define "n8n.encryptionKeySecretName" -}}
{{- $config := .Values.config | default dict -}}
{{- $existingSecret := $config.existingEncryptionKeySecret | default "" -}}
{{- $existingSecret | default (printf "%s-encryption-key" (include "n8n.fullname" .)) }}
{{- end }}

{{/*
Constructs the PostgreSQL host.
It will use the host defined in .Values.externalPostgresql.host (passed from parent).
The `tpl` function is used to render any Helm templating (like {{ .Release.Name }})
that might be present in the host value from the parent chart.
If .Values.externalPostgresql.host is not defined, it falls back to a constructed name.
*/}}
{{- define "n8n.postgresql.host" -}}
  {{- $extPg := .Values.externalPostgresql | default dict -}}
  {{- $hostValue := $extPg.host | default (printf "%s-postgresql" .Release.Name) -}}
  {{- tpl $hostValue . -}}
{{- end -}}

{{/*
Constructs the Redis host.
It will use the host defined in .Values.externalRedis.host (passed from parent).
The `tpl` function is used to render any Helm templating.
If .Values.externalRedis.host is not defined, it falls back to a constructed name.
*/}}
{{- define "n8n.redis.host" -}}
  {{- $extRedis := .Values.externalRedis | default dict -}}
  {{- $hostValue := $extRedis.host | default (printf "%s-redis-master" .Release.Name) -}}
  {{- tpl $hostValue . -}}
{{- end -}}