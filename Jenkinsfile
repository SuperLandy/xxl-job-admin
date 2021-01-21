pipeline {
    agent any
    environment {
		base_url = "https://hub.fastgit.org/SuperLandy"
		
		git_user_email = "752331557@qq.com"
		git_user_name  = "zhiqiang226"
		
        app_name = 'xxl-job-admin'
		deployment_name = 'xxl-job-admin-deployment'
		
        app_git_url = "${base_url}/${app_name}.git"
		deploy_git_url = "${base_url}/${deployment_name}.git"
		
		IMAGE_MASTER = "harbor.huaweicloud.com/test-env/xxl-job-admin:v${BUILD_NUMBER}"
		IMAGE_NODE = "harbor.huaweicloud.com/test-env/xxl-job-executor:v${BUILD_NUMBER}"
    }
    
    stages {
        stage('1.Git 代码检出') {
            steps {
				deleteDir()
                dir("${app_name}"){
					git changelog: true, poll: false, url: "$env.app_git_url"
					script {
					  env.AUTHOR = sh (returnStdout: true, script: '#!/bin/sh -e\n git log -1 --pretty=%an').trim()
					  env.GIT_COMMIT_MSG = sh (returnStdout: true, script: '#!/bin/sh -e\n git log -1 --pretty=%B').trim()
					}
				}
            }

        }

        stage('2. 代码扫描测试') {
			parallel {
				stage('2.1 sonarqube 扫描') {
					steps {
						dir("${app_name}"){
							withSonarQubeEnv('sonarqube-huaweicloud') {
								sh 'sonar-scanner \
									-Dsonar.projectKey=$app_name \
									-Dsonar.projectName=$app_name \
									-Dsonar.sourceEncoding=UTF-8 \
									-Dsonar.projectBaseDir=. \
									-Dsonar.language=java \
									-Dsonar.sources=. \
									-Dsonar.java.binaries=.'
							}
						}
					}
				}
				stage('2.2 maven单元测试') {
					steps {
						dir("${app_name}"){
							sh 'mvn  surefire-report:report test  -Dmaven.test.skip=false -Dmaven.test.failure.ignore=false'
							findText(textFinders: [textFinder(regexp: 'There are test failures',alsoCheckConsoleOutput: true,buildResult: 'ABORTED')])
							publishHTML (target : [allowMissing: false,
								 alwaysLinkToLastBuild: true,
								 keepAll: true,
								 reportDir: './xxl-job-admin/target/site/',
								 reportFiles: 'surefire-report.html',
								 reportName: '单元测试报告',
								 reportTitles: '单元测试报告'])
							// 配置单元测试覆盖率要求，未达到要求pipeline将会fail,code coverage.LineCoverage>20%.
							jacoco() 
						}
					}
				}
			}
		}
        stage('3. 测试报告') {
            steps {
				dir("${app_name}"){
					allure disabled: false, includeProperties: false, jdk: '', results: [[path: 'xxl-job-admin/target/surefire-reports']]
				}
            }
        }
        stage('4. sonarqube质量关卡') {
            steps {
				dir("${app_name}"){
					script {
						sleep(10)
						timeout(1) {
							def qualitygate = waitForQualityGate('sonarqube-huaweicloud')
							if (qualitygate.status != "OK") {
								error "Pipeline aborted due to quality gate coverage failure: ${qualitygate.status}"
							}
							else {echo 'sonarqube质量关卡 PASS!!'}
						}
					}
				}
            }
        }
        stage('5. Maven 编译') {
			steps {
				dir("${app_name}"){
					// script {
					//     sh (returnStdout: true, script: '#!/bin/sh -e\n ').trim()
					// }
					sh 'mvn -U clean package -Dmaven.test.skip:truedependency:tree'
				}
			}
        }
		stage('6. 制品仓库') {
            steps {
				dir("${app_name}"){
					echo 'mevddddddn push'
				}
            }
        }
		stage('7.docker打包推送') {
			steps {
				dir("${app_name}"){
					script {
						MASTER_FILE_PATH = "./xxl-job-admin/target/xxl-job-admin-2.2.1-SNAPSHOT.jar"
						NODE_FILE_PATH = "./xxl-job-executor-samples/xxl-job-executor-sample-springboot/target/xxl-job-executor-sample-springboot-2.2.1-SNAPSHOT.jar"
						
						docker.withRegistry('http://harbor.huaweicloud.com'){
							docker.build("${IMAGE_MASTER}", "--build-arg JAR_FILE_PATH=${MASTER_FILE_PATH}  -f ./Dockerfile .").push()
							docker.build("${IMAGE_NODE}", "--build-arg JAR_FILE_PATH=${NODE_FILE_PATH}  -f ./Dockerfile .").push()
						}
					}
				}
			}
		}
        stage('8. k8s资源文件更新') {
            steps {
			    withCredentials([usernamePassword(credentialsId: 'git-password', passwordVariable: 'passwd', usernameVariable: 'user')]) {
					sh("git clone https://$user:$passwd@github.com/SuperLandy/xxl-job-admin-deployment.git")
					dir("$deployment_name") {
						sh """
							git config user.email "${git_user_email}"
							git config user.name "${git_user_name}"
							sed -i 's/xxl-job-admin:v[0-9]\\{1,9\\}/xxl-job-admin:v${BUILD_NUMBER}/g' xxl-job-admin/xxl-job-admin-deployment.yaml
							sed -i 's/xxl-job-executor:v[0-9]\\{1,9\\}/xxl-job-executor:v${BUILD_NUMBER}/g' xxl-job-executor/xxl-job-executor-deployment.yaml
							git add .
							git commit -m "author: ${AUTHOR}   commitmessage: ${GIT_COMMIT_MSG} "
							git push origin main
						"""
					}
				}
            }
        }

    }
	post {
		failure{
			echo '构建失败'
		}
		
		unstable {
			echo '单元测试失败，未通过代码扫描'
		}
		
		success {
			echo '构建成功'
        }
    }
}