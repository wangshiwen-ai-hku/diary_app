import os
from pathlib import Path
from dataclasses import asdict
from typing import Optional, Dict, Any

from src.config.manager import ConfigManager
from langchain.chat_models import init_chat_model
from langchain_core.messages import SystemMessage, HumanMessage


def build_model_conf_from_three_params(
    provider: str, model_id: str, base_url: Optional[str], api_key: Optional[str]
) -> Dict[str, Any]:
    """Map minimal user-provided params into the project's expected model dict.

    This allows quick testing with just provider/model/base_url while remaining
    compatible with `init_chat_model` used across the project.
    """
    return {
        "model_provider": provider,
        "model": model_id,
        "base_url": base_url,
        "api_key": api_key,
        "temperature": float(os.environ.get("TEST_MODEL_TEMPERATURE", "0.7")),
    }


# Try to load project config.yaml first; if that fails, fall back to
# using simple environment variables (provider, model id, base_url, api_key).
config_path = Path(__file__).resolve().parent.parent / "src" / "general" / "config.yaml"
try:
    config = ConfigManager(config_path)
    try:
        agent_config = config.get_agent_config("plan_agent", "core")
        model_conf = asdict(agent_config.model)
    except Exception:
        model_conf = asdict(config.get_model_config())
except Exception:
    provider = os.environ.get("TEST_MODEL_PROVIDER", "azure_openai")
    model_id = os.environ.get("TEST_MODEL_ID", "xinzhewei-gpt5mini")
    base_url = os.environ.get("TEST_BASE_URL", "https://routinetask.cognitiveservices.azure.com/")
    api_key = os.environ.get("TEST_API_KEY")
    model_conf = build_model_conf_from_three_params(provider, model_id, base_url, api_key)


# Initialize the model using the project's common entrypoint.
llm = init_chat_model(**model_conf)

system_msg = SystemMessage(content="You are a helpful assistant.")
user_msg = HumanMessage(content="I am going to Paris, what should I see?")

response_text = None
try:
    # Prefer the .generate interface if supported by the model wrapper
    result = llm.generate([[system_msg, user_msg]])
    gens = getattr(result, "generations", None)
    if gens and len(gens) and len(gens[0]):
        response_text = getattr(gens[0][0], "text", str(gens[0][0]))
    else:
        response_text = str(result)
except Exception:
    try:
        # Fallback: call the model as a callable
        result = llm([system_msg, user_msg])
        if isinstance(result, str):
            response_text = result
        else:
            response_text = getattr(result, "content", str(result))
    except Exception as e:
        response_text = f"Model call failed: {e}"

print(response_text)