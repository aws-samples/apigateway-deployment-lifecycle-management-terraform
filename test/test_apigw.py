import pytest
import tftest
from pprint import pprint


@pytest.fixture
def plan(directory="../", module_name="api-gw-redeployment-management"):
    tf = tftest.TerraformTest(module_name, directory)
    tf.setup(
        use_cache=True,
        cleanup_on_exit=False,
    )
    plan = tf.plan(
        output=True,
        use_cache=True,
    )
    return plan


def test_variables(plan):
    pprint(f"DEBUG PLAN: {plan}")
    tf_vars = plan.variables

    assert "deployments" in tf_vars
    assert "rollback" in tf_vars
    assert "reverse_ids" in tf_vars


def test_resources_are_planned(plan):

    pprint(f"DEBUG PLAN: {plan}")
    resources = plan.resources
    assert "aws_api_gateway_rest_api.example" in resources
    assert "aws_api_gateway_method.example" in resources
    assert 'aws_api_gateway_deployment.example["a"]' in resources
