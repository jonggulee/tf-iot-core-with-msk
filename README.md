# AWS IoT Core와 MSK 연동 실습

본 저장소는 Terraform 기반으로 AWS IoT Core와 MSK 간 연동을 자동화하는 데모 프로젝트입니다.  
AWS IoT Core에서 수신한 MQTT 메시지를 Amazon MSK(Kafka)로 전달하는 인프라 구성을 목표로 합니다.

---

## 구성 아키텍처

- **IoT Core**: MQTT 브로커 역할
- **IoT Rule**: MQTT 메시지를 Kafka로 전달
- **MSK (Kafka)**: 실시간 메시지 수신
- **Secrets Manager + KMS**: SCRAM 인증 정보 저장 및 암호화
- **IAM Role**: IoT Rule이 MSK에 접근할 수 있도록 권한 부여
- **VPC, Subnet, SG**: 전체 네트워크 및 보안 환경 구성


---

## 주요 모듈

| 리소스 (Resource)         | 설명 (Description) |
|---------------------------|---------------------|
| `module.vpc`              | VPC 및 서브넷 구성
| `module.iam_role_msk`     | IoT Rule용 IAM 역할
| `module.secrets_manager_msk` | 인증 정보 저장
| `module.msk_cluster`      | MSK 클러스터 생성
| `aws_iot_topic_rule_destination` | VPC 대상 생성
| `aws_iot_topic_rule`      | 메시지 라우팅 규칙

---

## 적용 방법

```bash
git clone https://github.com/your-org/tf-iot-core-with-msk.git
cd tf-iot-core-with-msk

terraform init
terraform plan
terraform apply
```

> 💡 클러스터 생성에는 약 20~30분이 소요될 수 있습니다.  

---

## 인증 정보

Secrets Manager에는 다음 형식의 JSON을 저장합니다:  
In Secrets Manager, the following credentials must be saved:

```json
{
  "username": "iotcore-test",
  "password": "iotcore-test-password"
}
```


---

## 전제 조건

- Terraform ≥ 1.3
- AWS CLI 인증 (`aws configure`)
- MSK, KMS, Secrets Manager, IoT Core 권한  
  Permissions for MSK, KMS, Secrets Manager, and IoT Core

---

## 주의사항

- 실습용 리소스는 요금이 발생할 수 있으며, 사용 후 반드시 `terraform destroy`로 삭제해주세요.  
  Resources may incur AWS costs. Remember to destroy them after testing.
- 실제 운영 환경에서는 IAM 최소 권한 원칙을 준수하고, Secret은 별도로 관리해야 합니다.  
  Follow least privilege principles and manage secrets securely in production.

---

## 블로그

상세한 내용은 아래 블로그에서 확인하실 수 있습니다.

[AWS IoT Core 서비스와 MSK 연동하기](https://medium.com/@jg.jake.lee/aws-iot-core-%EC%84%9C%EB%B9%84%EC%8A%A4%EC%99%80-msk-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0-bfd9c48c9c44)