# TBPICK — Rails → Spring Boot + React migration

This directory now contains three things:

1. The **original Rails app** (root `/app`, `/config`, `/db`, etc.) — left untouched.
2. **`spring-boot-backend/`** — the new Spring Boot 3 / Java 17 backend.
3. **`react-frontend/`** — the new React 18 + Vite + TypeScript frontend.

Both new projects are stand-alone: they have their own build files, their own
README sections (below), and they don't reach into the Rails source.

This first pass is a **skeleton + the picking flow end-to-end**. It contains:

- Postgres schema migration that mirrors the Rails `db/schema.rb` for the tables
  needed by the picking flow (`users`, `clients`, `client_locations`, `waves`,
  `picks`, `permits`).
- JPA entities for those tables plus read-only entities for the two Oracle ERP
  views the Rails app reads (`tbpick_orders_vw`, `tbpick_order_lines_vw`).
- Spring Security + JWT auth that replaces Devise (BCrypt is used so existing
  Devise password hashes remain verifiable).
- A faithful port of the four core services:
  - `LinePickService` — same per-pick "actual quantity" rules as the Rails one
  - `PickSequencerService` — the wave creation + bulk/drop/pick generation
  - `PickFinisherService` — Oracle write-back orchestration (gateway is stubbed)
  - `PermitService` — the `action_permitted?` logic from the Rails controllers
- REST controllers for Orders, OrderLines (`/orders/lines`) and Picks.
- A React frontend with Login, Orders selection, and the Picks worksheet,
  wired against the Spring Boot API via Axios + React Router.

Things that are deliberately left as TODO and are flagged in code:

- **Multi-tenant Oracle datasource resolver.** The Rails app calls
  `Order.using(client.cust_no)` to switch the AR connection per client.
  In Spring this needs an `AbstractRoutingDataSource` (or a per-tenant
  `EntityManagerFactory`) keyed off the JWT's `cid` claim. The two Oracle
  entities are mapped against the same EM in this skeleton so dev can run
  without an Oracle instance.
- **Aisle TSP optimizer** — the inner loop of `pick_sequencer.rb`
  (`optimize_aisle`/`record_results`) depends on the Oracle `tb_aisle*`,
  `tb_area_struct`, `tb_area_shortcut` and `bulk_stock_loc` views. The
  `DefaultAisleOptimizer` falls back to a deterministic lex sort so the wave
  flow is exercisable; replace with the warehouse-aware version once those
  entities are ported.
- **Oracle ERP write-back** — `StubOracleErpGateway` logs intent. Wire to a
  real JDBC implementation when `PickMove` / `PickOrderLine` / `PickWave`
  are ported.
- **The other ~20 controllers / 50 models** (admin, binpick_*, receipt_*,
  carriers, page_requests, dashboards, mailers, etc.) are not yet converted.
  They follow the same pattern; the next iteration can copy the Orders/Picks
  layout for any one of them.

---

## Rails → Spring/React mapping

| Rails artefact                                   | New location                                                                   |
| ------------------------------------------------ | ------------------------------------------------------------------------------ |
| `config/routes.rb` (orders/picks subset)         | `web/controller/OrderController.java`, `web/controller/PickController.java`     |
| `config/database.yml` development                | `application.yml` (`spring.datasource.*`)                                       |
| `db/schema.rb`                                   | `src/main/resources/db/migration/V1__init_schema.sql` (Flyway)                  |
| `app/models/user.rb` (Devise)                    | `domain/pg/User.java` + Spring Security in `config/SecurityConfig.java`         |
| `app/models/client.rb`                           | `domain/pg/Client.java`                                                          |
| `app/models/wave.rb`                             | `domain/pg/Wave.java`                                                            |
| `app/models/pick.rb`                             | `domain/pg/Pick.java` + `domain/pg/PickType.java`                                |
| `app/models/permit.rb`                           | `domain/pg/Permit.java`                                                          |
| `app/models/order.rb` (Oracle view)              | `domain/oracle/Order.java`                                                       |
| `app/models/order_line.rb` (Oracle view)         | `domain/oracle/OrderLine.java`                                                   |
| `app/services/line_pick_service.rb`              | `service/LinePickService.java`                                                   |
| `app/services/pick_sequencer.rb`                 | `service/PickSequencerService.java` + `service/DefaultAisleOptimizer.java`       |
| `app/services/pick_finisher.rb`                  | `service/PickFinisherService.java` + `service/StubOracleErpGateway.java`         |
| `app/controllers/orders_controller.rb`           | `web/controller/OrderController.java`                                            |
| `app/controllers/order_lines_controller.rb`      | `web/controller/OrderController.java#lines`                                      |
| `app/controllers/picks_controller.rb`            | `web/controller/PickController.java`                                             |
| `app/views/orders/index.html.erb`                | `react-frontend/src/pages/OrdersPage.tsx`                                        |
| `app/views/picks/index.html.erb`                 | `react-frontend/src/pages/PicksPage.tsx`                                         |
| `app/views/devise/sessions/new.html.erb`         | `react-frontend/src/pages/LoginPage.tsx`                                         |
| `app/views/layouts/application.html.erb`         | `react-frontend/src/components/Layout.tsx`                                       |

---

## Running it locally

### Backend

Prereqs: Java 17+, Maven 3.9+, Postgres 14+ (running and reachable with the
credentials in `application.yml` — defaults match the Rails `development`
profile: db `tbcorp_development`, user `postgres`, password `root`, host
`localhost`).

```bash
cd spring-boot-backend
./mvnw spring-boot:run         # or: mvn spring-boot:run
# API now on http://localhost:8080/api
```

Smoke test once it's up:
```bash
curl -s http://localhost:8080/api/health
```

To run the bundled context-load test (uses H2, no Postgres needed):
```bash
./mvnw -Dtest=TbpickApplicationTests test
```

### Frontend

Prereqs: Node 18+, npm 9+.

```bash
cd react-frontend
npm install
npm run dev      # http://localhost:5173
```

The Vite dev server proxies `/api/*` to `http://localhost:8080`, so the
frontend can call e.g. `GET /api/orders` without CORS hassle.

---

## Pick-flow walkthrough (ported behavior)

1. Host user signs in (`POST /api/auth/login`, JWT issued).
2. Browses orders for the active client (`GET /api/orders?clientId=...`).
   Orders that another user is currently picking are filtered out — the
   Rails `exclude_orders` rule.
3. Selects orders and hits **Start pick**.
4. `POST /api/picks/start` → `PickSequencerService.run`:
   - Pulls the order lines from the Oracle view.
   - Builds a per-bin aggregate.
   - Identifies bins where demand > on-hand and emits a (bulk, drop) pick pair.
   - Emits one pick row per order line.
   - Persists Wave + Picks. Empty waves are deleted.
5. Frontend routes to `/picks` — `GET /api/picks?clientId=...`.
6. User confirms each pick line (`PUT /api/picks/{id}` with `picked` +
   `actualQty`). `LinePickService` enforces the same min-of-planned-vs-actual
   rule the Rails service did.
7. **Picking complete** → `POST /api/picks/finish?clientId=...`:
   - Iterates bulk picks with non-zero actual qty → `OracleErpGateway.writePickMove`
   - Iterates pick rows with non-zero actual qty → `OracleErpGateway.writePickOrderLine`
   - Signals wave complete → `OracleErpGateway.signalWaveComplete`
   - Locally deletes the picks then the wave.
   - On failure, the local picks are preserved so the user can retry — same
     contract as the Rails finisher.
