import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service(#{ title: "Summeryme AI API" })
@server("http://localhost:3000", "Local development server")
namespace SummerymeAPI {
  // Common models
  model PaginationQuery {
    @query
    @minValue(1)
    page?: int32 = 1;

    @query
    @minValue(1)
    @maxValue(100)
    limit?: int32 = 10;
  }

  model PaginationResponse {
    currentPage: int32;
    totalPages: int32;
    totalCount: int32;
    limit: int32;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  }

  model ErrorResponse {
    error: string;
    details?: ValidationError[];
  }

  model ValidationError {
    field: string;
    message: string;
  }

  // SavedArticle models
  model SavedArticle {
    id: int32;
    userId: int32;
    title: string;
    url: string;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model CreateSavedArticleRequest {
    @minLength(1)
    @maxLength(255)
    title: string;

    @maxLength(1024)
    url: string;
  }

  model SavedArticleResponse {
    data: SavedArticle;
    message?: string;
  }

  model SavedArticlesListResponse {
    data: SavedArticle[];
    pagination: PaginationResponse;
  }

  // UserDailySummary models
  model UserDailySummary {
    id: int32;
    userId: int32;
    audioFileUrl: string | null;
    summeryText: string;
    summeryDate: plainDate;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
    user?: User;
  }

  model User {
    id: int32;
    email: string;
    name: string | null;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model UserDailySummaryResponse {
    data: UserDailySummary;
  }

  model UserDailySummariesListResponse {
    data: UserDailySummary[];
    pagination: PaginationResponse;
  }

  // Health check models
  model HealthCheckResponse {
    status: "healthy" | "unhealthy";
    timestamp: string;
    database?: {
      status: "connected" | "disconnected";
    };
  }

  // API Routes
  @route("/api/saved-articles")
  interface SavedArticles {
    @get
    list(...PaginationQuery): SavedArticlesListResponse | ErrorResponse;

    @post
    create(@body body: CreateSavedArticleRequest): {
      @statusCode statusCode: 201;
      @body body: SavedArticleResponse;
    } | ErrorResponse;

    @get
    @route("{id}")
    getById(@path id: int32): SavedArticleResponse | {
      @statusCode statusCode: 404;
      @body body: ErrorResponse;
    };

    @delete
    @route("{id}")
    deleteById(@path id: int32): {
      @statusCode statusCode: 200;
      @body body: {
        message: string;
      };
    } | {
      @statusCode statusCode: 404;
      @body body: ErrorResponse;
    };
  }

  @route("/api/user-daily-summaries")
  interface UserDailySummaries {
    @get
    list(...PaginationQuery): UserDailySummariesListResponse | ErrorResponse;

    @get
    @route("{id}")
    getById(@path id: int32): UserDailySummaryResponse | {
      @statusCode statusCode: 404;
      @body body: ErrorResponse;
    };
  }

  // Health check endpoints
  @route("/health")
  @get
  op healthCheck(): HealthCheckResponse;

  @route("/health/basic")
  @get
  op basicHealthCheck(): HealthCheckResponse;
}