"""
Part 1: Basic Research Paper Search Agent with ADK Web

This agent demonstrates how to observe agent behavior using ADK web's built-in
observability features. Shows a research paper search agent with logging.

Run with: adk web --log_level DEBUG
Then open http://127.0.0.1:8000 and select this agent.
"""

from google.adk.agents import LlmAgent
from google.adk.tools.google_search_tool import google_search
from google.adk.tools.agent_tool import AgentTool

def format_search_query(topic: str) -> dict:
    """Formats a research topic into optimized search queries for academic papers."""
    print(f"🔧 Formatting search query for: {topic}")

    topic = topic.strip()

    if not topic:
        return {
            "status": "error",
            "message": "Topic cannot be empty"
        }

    # Create optimized search queries for different academic sources
    queries = {
        "arxiv_query": f'site:arxiv.org "{topic}" abstract',
        "ieee_query": f'site:ieeexplore.ieee.org "{topic}" paper',
        "acm_query": f'site:dl.acm.org "{topic}" research',
        "general_query": f'"{topic}" research paper pdf filetype:pdf',
        "recent_query": f'"{topic}" paper 2023..2024 arxiv'
    }

    return {
        "status": "success",
        "topic": topic,
        "optimized_queries": queries,
        "recommended_query": queries["arxiv_query"],
        "search_tips": [
            f'Try searching: {queries["arxiv_query"]}',
            f'For recent papers: {queries["recent_query"]}',
            f'For IEEE papers: {queries["ieee_query"]}'
        ]
    }

# Create a specialized search agent for research papers
research_search_agent = LlmAgent(
    name="research_search_agent",
    model="gemini-2.0-flash",
    description="Specialized agent for finding academic research papers using Google search.",
    instruction="""You are a research paper search specialist. You will be given a search query. Use that query to do a google search:

1. Use Google search for the given query.
2. Focus on academic sources like arxiv, pubmed, IEEE, ACM digital library
3. Search for papers with accessible abstracts and key findings
4. Present the papers you found with clear summaries
5. If search fails, suggest alternative search terms

Always provide paper titles, authors, abstracts when available, and explain relevance.""",
    tools=[google_search]
)


# Create the research paper search agent
root_agent = LlmAgent(
    name="paper_search_agent",
    model="gemini-2.0-flash",
    description="A research paper search agent that uses Google search to find academic papers.",
    instruction="""You are a research paper search assistant. When users ask about research topics:

1. First use format_search_query to optimize the search terms for academic sources
2. Use the optimized queries with Google search to find relevant papers
3. Focus your searches on academic sources like arxiv, pubmed, IEEE, ACM, etc.
4. Present the papers with clear summaries of their key contributions
5. Help users understand complex research concepts in accessible terms

Always start with the format_search_query tool to get better search results.""",
    tools=[format_search_query, AgentTool(agent=research_search_agent)],
)